#include "playerSpaceship.h"

static const int16_t CMD_TARGET_ROTATION = 0x0001;
static const int16_t CMD_IMPULSE = 0x0002;
static const int16_t CMD_WARP = 0x0003;
static const int16_t CMD_JUMP = 0x0004;
static const int16_t CMD_SET_TARGET = 0x0005;
static const int16_t CMD_LOAD_TUBE = 0x0006;
static const int16_t CMD_UNLOAD_TUBE = 0x0007;
static const int16_t CMD_FIRE_TUBE = 0x0008;
static const int16_t CMD_SET_SHIELDS = 0x0009;
static const int16_t CMD_SET_MAIN_SCREEN_SETTING = 0x000A;
static const int16_t CMD_SCAN_OBJECT = 0x000B;
static const int16_t CMD_SET_SYSTEM_POWER = 0x000C;
static const int16_t CMD_SET_SYSTEM_COOLANT = 0x000D;

REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");

PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship")
{
    energy_level = 1000;
    mainScreenSetting = MSS_Front;
    factionId = 1;
    hull_damage_indicator = 0.0;
    scanned_by_player = true;

    registerMemberReplication(&hull_damage_indicator, 0.5);
    registerMemberReplication(&energy_level);
    registerMemberReplication(&jumpSpeedFactor);
    registerMemberReplication(&beamRechargeFactor);
    registerMemberReplication(&tubeRechargeFactor);
    registerMemberReplication(&mainScreenSetting);
    registerMemberReplication(&scanning_delay, 0.5);
    registerMemberReplication(&front_shield_recharge_factor);
    registerMemberReplication(&rear_shield_recharge_factor);
    
    for(int n=0; n<PS_COUNT; n++)
    {
        systems[n].health = 1.0;
        systems[n].powerLevel = 1.0;
        systems[n].coolantLevel = 0.0;
        systems[n].heatLevel = 0.0;
        
        registerMemberReplication(&systems[n].health);
        registerMemberReplication(&systems[n].powerLevel);
        registerMemberReplication(&systems[n].coolantLevel);
        registerMemberReplication(&systems[n].heatLevel, 1.0);
    }
    systems[PS_Reactor].powerUserFactor = -30.0;
    systems[PS_BeamWeapons].powerUserFactor = 3.0;
    systems[PS_MissileSystem].powerUserFactor = 1.0;
    systems[PS_Maneuver].powerUserFactor = 2.0;
    systems[PS_Impulse].powerUserFactor = 4.0;
    systems[PS_Warp].powerUserFactor = 6.0;
    systems[PS_JumpDrive].powerUserFactor = 6.0;
    systems[PS_FrontShield].powerUserFactor = 5.0;
    systems[PS_RearShield].powerUserFactor = 5.0;
}

void PlayerSpaceship::update(float delta)
{
    if (hull_damage_indicator > 0)
        hull_damage_indicator -= delta;
    
    if (gameServer)
    {
        if (shields_active)
            useEnergy(delta * energy_shield_use_per_second);
        
        for(int n=0; n<PS_COUNT; n++)
        {
            if (n == PS_Warp && !hasWarpdrive) continue;
            if (n == PS_JumpDrive && !hasJumpdrive) continue;
            
            if (systems[n].powerUserFactor < 0.0)   //When we generate power, use the health of this system in the equation
                energy_level -= delta * systems[n].powerUserFactor * systems[n].health * systems[n].powerLevel * 0.02;
            else
                energy_level -= delta * systems[n].powerUserFactor * systems[n].powerLevel * 0.02;
            systems[n].heatLevel += delta * powf(1.7, systems[n].powerLevel - 1.0) * system_heatup_per_second;
            systems[n].heatLevel -= delta * (1.0 + systems[n].coolantLevel * 0.1) * system_heatup_per_second;
            if (systems[n].heatLevel > 1.0)
            {
                systems[n].heatLevel = 1.0;
                systems[n].health -= delta * damage_per_second_on_overheat;
                if (systems[n].health < 0.0)
                    systems[n].health = 0.0;
            }
            if (systems[n].heatLevel < 0.0)
                systems[n].heatLevel = 0.0;
        }
        if (energy_level < 0.0)
            energy_level = 0.0;
        float max_power_level = 3.0;
        if (energy_level < 10.0)
        {
            //Out of energy, we do not care how much power you put into systems, everything is bad now.
            max_power_level = 0.1;
            shields_active = false;
        }
        beamRechargeFactor = std::min(systems[PS_BeamWeapons].powerLevel * systems[PS_BeamWeapons].health, max_power_level);
        tubeRechargeFactor = std::min(systems[PS_MissileSystem].powerLevel * systems[PS_MissileSystem].health, max_power_level);
        rotationSpeed = shipTemplate->turnSpeed * std::min(systems[PS_Maneuver].powerLevel * systems[PS_Maneuver].health, max_power_level);
        impulseMaxSpeed = shipTemplate->impulseSpeed * std::min(systems[PS_Impulse].powerLevel * systems[PS_Impulse].health, max_power_level);
        warpSpeedPerWarpLevel = shipTemplate->warpSpeed * std::min(systems[PS_Warp].powerLevel * systems[PS_Warp].health, max_power_level);
        jumpSpeedFactor = std::min(systems[PS_JumpDrive].powerLevel * systems[PS_JumpDrive].health, max_power_level);
        front_shield_recharge_factor = std::min(systems[PS_FrontShield].powerLevel * systems[PS_FrontShield].health, max_power_level);
        rear_shield_recharge_factor = std::min(systems[PS_RearShield].powerLevel * systems[PS_RearShield].health, max_power_level);

        if (hasWarpdrive && warpRequest > 0 && !(hasJumpdrive && jumpDelay > 0))
        {
            if (!useEnergy(energy_warp_per_second * delta * float(warpRequest * warpRequest) * (shields_active ? 1.5 : 1.0)))
                warpRequest = 0;
        }
        if (scanning_ship)
        {
            scanning_delay -= delta;
            if (scanning_delay < 0)
            {
                scanning_ship->scanned_by_player = true;
                scanning_ship = NULL;
            }
        }else{
            scanning_delay = 0.0;
        }
    }else{
        //Client side
        if (scanning_delay > 0.0)
            scanning_delay -= delta;
    }
    
    SpaceShip::update(delta);

    if (energy_level > 1000.0)
        energy_level = 1000.0;
}

void PlayerSpaceship::executeJump(float distance)
{
    if (useEnergy(distance * energy_per_jump_km) && systems[PS_JumpDrive].health > 0.0)
        SpaceShip::executeJump(distance);
}

void PlayerSpaceship::fireBeamWeapon(int idx, P<SpaceObject> target)
{
    if (useEnergy(energy_per_beam_fire))
        SpaceShip::fireBeamWeapon(idx, target);
}

void PlayerSpaceship::hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type)
{
    if (type != DT_EMP)
    {
        hull_damage_indicator = 0.5;
        EPlayerSystem random_system = EPlayerSystem(irandom(0, PS_COUNT - 1));
        //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
        float system_damage = (damageAmount / hull_max) * 5.0;
        if (type == DT_Kinetic)
            system_damage *= 2.0;   //Missile weapons do more system damage, as they penetrate the hull easier.
        systems[random_system].health -= system_damage;
        if (systems[random_system].health < 0.0)
            systems[random_system].health = 0.0;
    }
    SpaceShip::hullDamage(damageAmount, damageLocation, type);
}

void PlayerSpaceship::setSystemCoolant(EPlayerSystem system, float level)
{
    float total_coolant = 0;
    int cnt = 0;
    for(int n=0; n<PS_COUNT; n++)
    {
        if (n == PS_Warp && !hasWarpdrive) continue;
        if (n == PS_JumpDrive && !hasJumpdrive) continue;
        if (n == system) continue;
        
        total_coolant += systems[n].coolantLevel;
        cnt++;
    }
    if (total_coolant > maxCoolant - level)
    {
        for(int n=0; n<PS_COUNT; n++)
        {
            if (n == PS_Warp && !hasWarpdrive) continue;
            if (n == PS_JumpDrive && !hasJumpdrive) continue;
            if (n == system) continue;
            
            systems[n].coolantLevel *= (maxCoolant - level) / total_coolant;
        }        
    }
    
    systems[system].coolantLevel = level;
}

void PlayerSpaceship::onReceiveCommand(int32_t clientId, sf::Packet& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_TARGET_ROTATION:
        packet >> targetRotation;
        break;
    case CMD_IMPULSE:
        packet >> impulseRequest;
        break;
    case CMD_WARP:
        packet >> warpRequest;
        break;
    case CMD_JUMP:
        {
            float distance;
            packet >> distance;
            initJump(distance);
        }
        break;
    case CMD_SET_TARGET:
        {
            packet >> targetId;
        }
        break;
    case CMD_LOAD_TUBE:
        {
            int8_t tubeNr;
            EMissileWeapons type;
            packet >> tubeNr >> type;
            
            loadTube(tubeNr, type);
        }
        break;
    case CMD_UNLOAD_TUBE:
        {
            int8_t tubeNr;
            packet >> tubeNr;
            
            if (tubeNr >= 0 && tubeNr < maxWeaponTubes && weaponTube[tubeNr].state == WTS_Loaded)
            {
                weaponTube[tubeNr].state = WTS_Unloading;
                weaponTube[tubeNr].delay = tubeLoadTime;
            }
        }
        break;
    case CMD_FIRE_TUBE:
        {
            int8_t tubeNr;
            packet >> tubeNr;
            
            fireTube(tubeNr);
        }
        break;
    case CMD_SET_SHIELDS:
        packet >> shields_active;
        break;
    case CMD_SET_MAIN_SCREEN_SETTING:
        packet >> mainScreenSetting;
        break;
    case CMD_SCAN_OBJECT:
        {
            int32_t id;
            packet >> id;
            
            P<SpaceShip> ship = gameServer->getObjectById(id);
            if (ship)
            {
                scanning_ship = ship;
                scanning_delay = 8.0;
            }
        }
        break;
    case CMD_SET_SYSTEM_POWER:
        {
            EPlayerSystem system;
            float level;
            packet >> system >> level;
            if (system < PS_COUNT && level >= 0.0 && level <= 3.0)
                systems[system].powerLevel = level;
        }
        break;
    case CMD_SET_SYSTEM_COOLANT:
        {
            EPlayerSystem system;
            float level;
            packet >> system >> level;
            if (system < PS_COUNT && level >= 0.0 && level <= 10.0)
                setSystemCoolant(system, level);
        }
        break;
    }
}

void PlayerSpaceship::commandTargetRotation(float target)
{
    sf::Packet packet;
    packet << CMD_TARGET_ROTATION << target;
    sendCommand(packet);
}

void PlayerSpaceship::commandImpulse(float target)
{
    sf::Packet packet;
    packet << CMD_IMPULSE << target;
    sendCommand(packet);
}

void PlayerSpaceship::commandWarp(int8_t target)
{
    sf::Packet packet;
    packet << CMD_WARP << target;
    sendCommand(packet);
}

void PlayerSpaceship::commandJump(float distance)
{
    sf::Packet packet;
    packet << CMD_JUMP << distance;
    sendCommand(packet);
}

void PlayerSpaceship::commandSetTarget(P<SpaceObject> target)
{
    sf::Packet packet;
    if (target)
        packet << CMD_SET_TARGET << target->getMultiplayerId();
    else
        packet << CMD_SET_TARGET << int32_t(-1);
    sendCommand(packet);
}

void PlayerSpaceship::commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType)
{
    sf::Packet packet;
    packet << CMD_LOAD_TUBE << tubeNumber << missileType;
    sendCommand(packet);
}

void PlayerSpaceship::commandUnloadTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_UNLOAD_TUBE << tubeNumber;
    sendCommand(packet);
}

void PlayerSpaceship::commandFireTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_FIRE_TUBE << tubeNumber;
    sendCommand(packet);
}

void PlayerSpaceship::commandSetShields(bool enabled)
{
    sf::Packet packet;
    packet << CMD_SET_SHIELDS << enabled;
    sendCommand(packet);
}

void PlayerSpaceship::commandMainScreenSetting(EMainScreenSetting mainScreen)
{
    sf::Packet packet;
    packet << CMD_SET_MAIN_SCREEN_SETTING << mainScreen;
    sendCommand(packet);
}

void PlayerSpaceship::commandScan(P<SpaceObject> object)
{
    sf::Packet packet;
    packet << CMD_SCAN_OBJECT << object->getMultiplayerId();
    sendCommand(packet);
}

void PlayerSpaceship::commandSetSystemPower(EPlayerSystem system, float power_level)
{
    sf::Packet packet;
    packet << CMD_SET_SYSTEM_POWER << system << power_level;
    sendCommand(packet);
}

void PlayerSpaceship::commandSetSystemCoolant(EPlayerSystem system, float coolant_level)
{
    sf::Packet packet;
    packet << CMD_SET_SYSTEM_COOLANT << system << coolant_level;
    sendCommand(packet);
}

string getPlayerSystemName(EPlayerSystem system)
{
    switch(system)
    {
    case PS_Reactor: return "Reactor";
    case PS_BeamWeapons: return "Beam Weapons";
    case PS_MissileSystem: return "Missile System";
    case PS_Maneuver: return "Maneuvering";
    case PS_Impulse: return "Impulse Engines";
    case PS_Warp: return "Warp Drive";
    case PS_JumpDrive: return "Jump Drive";
    case PS_FrontShield: return "Front Shields";
    case PS_RearShield: return "Rear Shields";
    default:
        return "UNKNOWN";
    }
}
