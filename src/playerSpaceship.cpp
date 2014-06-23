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
    registerMemberReplication(&mainScreenSetting);
    registerMemberReplication(&scanning_delay, 0.5);
    
    for(int n=0; n<PS_COUNT; n++)
    {
        systems[n].health = 0.0;
        systems[n].powerLevel = 1.0;
        systems[n].heatLevel = 0.0;
        
        registerMemberReplication(&systems[n].health);
        registerMemberReplication(&systems[n].powerLevel);
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
            
            energy_level -= delta * systems[n].powerUserFactor * systems[n].powerLevel * 0.02;
            systems[n].heatLevel += delta * powf(1.5, systems[n].powerLevel - 1.0) * system_heatup_per_second;
            systems[n].heatLevel -= delta * (1.0 + systems[n].coolantLevel * 0.1) * system_heatup_per_second;
            if (systems[n].heatLevel > 1.0)
                systems[n].heatLevel = 1.0;
            if (systems[n].heatLevel < 0.0)
                systems[n].heatLevel = 0.0;
        }
        if (energy_level < 0.0)
            energy_level = 0.0;

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
    if (useEnergy(distance * energy_per_jump_km))
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
        hull_damage_indicator = 0.5;
    SpaceShip::hullDamage(damageAmount, damageLocation, type);
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
