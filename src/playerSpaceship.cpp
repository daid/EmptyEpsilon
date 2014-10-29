#include "playerSpaceship.h"
#include "repairCrew.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(PlayerSpaceship, SpaceShip)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getWaypoint);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getWaypointCount);
}

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
static const int16_t CMD_DOCK = 0x000E;
static const int16_t CMD_UNDOCK = 0x000F;
static const int16_t CMD_OPEN_TEXT_COMM = 0x0010; //TEXT communication
static const int16_t CMD_CLOSE_TEXT_COMM = 0x0011;
static const int16_t CMD_SEND_TEXT_COMM = 0x0012;
static const int16_t CMD_SEND_TEXT_COMM_PLAYER = 0x0013;
static const int16_t CMD_SET_AUTO_REPAIR = 0x0014;
static const int16_t CMD_OPEN_VOICE_COMM = 0x0015; // VOIP communication
static const int16_t CMD_CLOSE_VOICE_COMM = 0x0016;
static const int16_t CMD_SEND_VOICE_COMM = 0x0017;
static const int16_t CMD_SET_BEAM_FREQUENCY = 0x0018;
static const int16_t CMD_SET_SHIELD_FREQUENCY = 0x0019;
static const int16_t CMD_ADD_WAYPOINT = 0x001A;
static const int16_t CMD_REMOVE_WAYPOINT = 0x001B;
static const int16_t CMD_ACTIVATE_SELF_DESTRUCT = 0x001C;
static const int16_t CMD_CANCEL_SELF_DESTRUCT = 0x001D;
static const int16_t CMD_CONFIRM_SELF_DESTRUCT = 0x001E;

REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");

PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship")
{
    energy_level = 1000;
    main_screen_setting = MSS_Front;
    faction_id = 1;
    hull_damage_indicator = 0.0;
    warp_indicator = 0.0;
    scanned_by_player = SS_FullScan;
    comms_state = CS_Inactive;
    comms_open_delay = 0.0;
    comms_reply_count = 0;
    shield_calibration_delay = 0.0;
    auto_repair_enabled = false;
    activate_self_destruct = false;

    updateMemberReplicationUpdateDelay(&targetRotation, 0.1);
    registerMemberReplication(&hull_damage_indicator, 0.5);
    registerMemberReplication(&hull_strength, 0.5);
    registerMemberReplication(&hull_max);
    registerMemberReplication(&warp_indicator, 0.5);
    registerMemberReplication(&energy_level);
    registerMemberReplication(&jumpSpeedFactor);
    registerMemberReplication(&beamRechargeFactor);
    registerMemberReplication(&tubeRechargeFactor);
    registerMemberReplication(&main_screen_setting);
    registerMemberReplication(&scanning_delay, 0.5);
    registerMemberReplication(&shields_active);
    registerMemberReplication(&shield_calibration_delay, 0.5);
    registerMemberReplication(&front_shield_recharge_factor);
    registerMemberReplication(&rear_shield_recharge_factor);
    registerMemberReplication(&auto_repair_enabled);
    registerMemberReplication(&comms_state);
    registerMemberReplication(&comms_open_delay, 1.0);
    registerMemberReplication(&comms_reply_count);
    registerMemberReplication(&comms_incomming_message);
    for (int n=0; n<max_comms_reply_count; n++)
        registerMemberReplication(&comms_reply[n].message);
    registerMemberReplication(&waypoints);
    registerMemberReplication(&activate_self_destruct);
    for(int n=0; n<max_self_destruct_codes; n++)
    {
        self_destruct_code[n] = 0;
        self_destruct_code_confirmed[n] = false;
        self_destruct_code_entry_position[n] = helmsOfficer;
        self_destruct_code_show_position[n] = helmsOfficer;
        registerMemberReplication(&self_destruct_code[n]);
        registerMemberReplication(&self_destruct_code_confirmed[n]);
        registerMemberReplication(&self_destruct_code_entry_position[n]);
        registerMemberReplication(&self_destruct_code_show_position[n]);
    }

    for(int n=0; n<SYS_COUNT; n++)
    {
        systems[n].health = 1.0;
        systems[n].power_level = 1.0;
        systems[n].coolant_level = 0.0;
        systems[n].heat_level = 0.0;

        registerMemberReplication(&systems[n].health);
        registerMemberReplication(&systems[n].power_level);
        registerMemberReplication(&systems[n].coolant_level);
        registerMemberReplication(&systems[n].heat_level, 1.0);
    }
    systems[SYS_Reactor].power_user_factor = -30.0;
    systems[SYS_BeamWeapons].power_user_factor = 3.0;
    systems[SYS_MissileSystem].power_user_factor = 1.0;
    systems[SYS_Maneuver].power_user_factor = 2.0;
    systems[SYS_Impulse].power_user_factor = 4.0;
    systems[SYS_Warp].power_user_factor = 6.0;
    systems[SYS_JumpDrive].power_user_factor = 6.0;
    systems[SYS_FrontShield].power_user_factor = 5.0;
    systems[SYS_RearShield].power_user_factor = 5.0;

    if (game_server)
    {
        for(int n=0; n<3; n++)
        {
            P<RepairCrew> rc = new RepairCrew();
            rc->ship_id = getMultiplayerId();
        }
    }
}

void PlayerSpaceship::update(float delta)
{
    if (hull_damage_indicator > 0)
        hull_damage_indicator -= delta;
    if (warp_indicator > 0)
        warp_indicator -= delta;
    if (shield_calibration_delay > 0)
    {
        shield_calibration_delay -= delta * (front_shield_recharge_factor + rear_shield_recharge_factor) / 2.0;
    }

    if (docking_state == DS_Docked)
    {
        energy_level += delta * 10.0;
        if (hull_strength < hull_max)
        {
            hull_strength += delta;
            if (hull_strength > hull_max)
                hull_strength = hull_max;
        }
    }

    if (game_server)
    {
        if (comms_state == CS_OpeningChannel)
        {
            if (comms_open_delay > 0)
            {
                comms_open_delay -= delta;
            }else{
                if (!comms_target || sf::length(getPosition() - comms_target->getPosition()) > max_comm_range)
                {
                    comms_state = CS_ChannelBroken;
                }else{
                    comms_reply_count = 0;
                    P<PlayerSpaceship> playerShip = comms_target;
                    if (playerShip)
                    {
                        if (playerShip->comms_state == CS_Inactive || playerShip->comms_state == CS_ChannelFailed || playerShip->comms_state == CS_ChannelBroken)
                        {
                            comms_state = CS_ChannelOpenPlayer;
                            comms_incomming_message = "Opened comms to " + playerShip->ship_template->name;
                            playerShip->comms_state = CS_ChannelOpenPlayer;
                            playerShip->comms_target = this;
                            playerShip->comms_incomming_message = "Incomming comms from " + playerShip->ship_template->name;
                        }else{
                            comms_state = CS_ChannelFailed;
                        }
                    }else{
                        if (comms_script_interface.openCommChannel(this, comms_target, comms_target->comms_script_name))
                            comms_state = CS_ChannelOpen;
                        else
                            comms_state = CS_ChannelFailed;
                    }
                }
            }
        }
        if (comms_state == CS_ChannelOpen || comms_state == CS_ChannelOpenPlayer)
        {
            if (!comms_target || sf::length(getPosition() - comms_target->getPosition()) > max_comm_range)
                comms_state = CS_ChannelBroken;
        }

        if (shields_active)
            useEnergy(delta * energy_shield_use_per_second);

        for(int n=0; n<SYS_COUNT; n++)
        {
            if (!hasSystem(ESystem(n))) continue;

            if (systems[n].power_user_factor < 0.0)   //When we generate power, use the health of this system in the equation
                energy_level -= delta * systems[n].power_user_factor * systems[n].health * systems[n].power_level * 0.02;
            else
                energy_level -= delta * systems[n].power_user_factor * systems[n].power_level * 0.02;
            systems[n].heat_level += delta * powf(1.7, systems[n].power_level - 1.0) * system_heatup_per_second;
            systems[n].heat_level -= delta * (1.0 + systems[n].coolant_level * 0.1) * system_heatup_per_second;
            if (systems[n].heat_level > 1.0)
            {
                systems[n].heat_level = 1.0;
                systems[n].health -= delta * damage_per_second_on_overheat;
                if (systems[n].health < 0.0)
                    systems[n].health = 0.0;
            }
            if (systems[n].heat_level < 0.0)
                systems[n].heat_level = 0.0;
        }

        if (systems[SYS_Reactor].health < 0.2 && systems[SYS_Reactor].heat_level == 1.0)
        {
            //Ok, you screwed up. Seriously, your reactor is heavy damaged and overheated. So it will explode.
            ExplosionEffect* e = new ExplosionEffect();
            e->setSize(1000.0f);
            e->setPosition(getPosition());

            SpaceObject::damageArea(getPosition(), 500, 30, 60, DT_Kinetic, 0.0);

            destroy();
            return;
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
        beamRechargeFactor = std::min(systems[SYS_BeamWeapons].power_level * systems[SYS_BeamWeapons].health, max_power_level);
        tubeRechargeFactor = std::min(systems[SYS_MissileSystem].power_level * systems[SYS_MissileSystem].health, max_power_level);
        rotationSpeed = ship_template->turnSpeed * std::min(systems[SYS_Maneuver].power_level * systems[SYS_Maneuver].health, max_power_level);
        impulseMaxSpeed = ship_template->impulseSpeed * std::min(systems[SYS_Impulse].power_level * systems[SYS_Impulse].health, max_power_level);
        warpSpeedPerWarpLevel = ship_template->warpSpeed * std::min(systems[SYS_Warp].power_level * systems[SYS_Warp].health, max_power_level);
        jumpSpeedFactor = std::min(systems[SYS_JumpDrive].power_level * systems[SYS_JumpDrive].health, max_power_level);
        front_shield_recharge_factor = std::min(systems[SYS_FrontShield].power_level * systems[SYS_FrontShield].health, max_power_level);
        rear_shield_recharge_factor = std::min(systems[SYS_RearShield].power_level * systems[SYS_RearShield].health, max_power_level);

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
                switch(scanning_ship->scanned_by_player)
                {
                case SS_NotScanned:
                    scanning_ship->scanned_by_player = SS_SimpleScan;
                    break;
                case SS_SimpleScan:
                    scanning_ship->scanned_by_player = SS_FullScan;
                    break;
                case SS_FullScan:
                    break;
                }
                scanning_ship = NULL;
            }
        }else{
            scanning_delay = 0.0;
        }

        if (activate_self_destruct)
        {
            bool do_self_destruct = true;
            for(int n=0; n<max_self_destruct_codes; n++)
                if (!self_destruct_code_confirmed[n])
                    do_self_destruct = false;
            if (do_self_destruct)
            {
                for(int n=0; n<5; n++)
                {
                    ExplosionEffect* e = new ExplosionEffect();
                    e->setSize(1000.0f);
                    e->setPosition(getPosition() + sf::rotateVector(sf::Vector2f(0, random(0, 500)), random(0, 360)));
                }

                SpaceObject::damageArea(getPosition(), 1500, 100, 200, DT_Kinetic, 0.0);

                destroy();
                return;
            }
        }
    }else{
        //Client side
        if (scanning_delay > 0.0)
            scanning_delay -= delta;
        if (comms_open_delay > 0)
            comms_open_delay -= delta;
    }

    SpaceShip::update(delta);

    if (energy_level > 1000.0)
        energy_level = 1000.0;
}

void PlayerSpaceship::executeJump(float distance)
{
    if (useEnergy(distance * energy_per_jump_km) && systems[SYS_JumpDrive].health > 0.0)
    {
        warp_indicator = 2.0;
        float f = systems[SYS_JumpDrive].health;
        distance = (distance * f) + (distance * (1.0 - f) * random(0.5, 1.5));
        SpaceShip::executeJump(distance);
    }
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
        hull_damage_indicator = 1.5;
        for(int n=0; n<10; n++)
        {
            ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
            //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
            float system_damage = (damageAmount / hull_max);
            if (type == DT_Kinetic)
                system_damage *= 2.0;   //Missile weapons do more system damage, as they penetrate the hull easier.
            systems[random_system].health -= system_damage;
            if (systems[random_system].health < 0.0)
                systems[random_system].health = 0.0;
        }
    }
    SpaceShip::hullDamage(damageAmount, damageLocation, type);
}

void PlayerSpaceship::setSystemCoolant(ESystem system, float level)
{
    float total_coolant = 0;
    int cnt = 0;
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (!hasSystem(ESystem(n))) continue;
        if (n == system) continue;

        total_coolant += systems[n].coolant_level;
        cnt++;
    }
    if (total_coolant > max_coolant - level)
    {
        for(int n=0; n<SYS_COUNT; n++)
        {
            if (!hasSystem(ESystem(n))) continue;
            if (n == system) continue;

            systems[n].coolant_level *= (max_coolant - level) / total_coolant;
        }
    }else{
        if (total_coolant > 0)
        {
            for(int n=0; n<SYS_COUNT; n++)
            {
                if (!hasSystem(ESystem(n))) continue;
                if (n == system) continue;

                systems[n].coolant_level *= (max_coolant - level) / total_coolant;
            }
        }
    }

    systems[system].coolant_level = level;
}

void PlayerSpaceship::setCommsMessage(string message)
{
    comms_incomming_message = message;
}

void PlayerSpaceship::addCommsReply(int32_t id, string message)
{
    if (comms_reply_count == max_comms_reply_count)
        return;
    comms_reply[comms_reply_count].id = id;
    comms_reply[comms_reply_count].message = message;
    comms_reply_count++;
}

void PlayerSpaceship::onReceiveClientCommand(int32_t clientId, sf::Packet& packet)
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
        {
            bool active;
            packet >> active;
            if (shield_calibration_delay <= 0.0 && active != shields_active)
            {
                shields_active = active;
                if (active)
                    soundManager.playSound("shield_up.wav");
                else
                    soundManager.playSound("shield_down.wav");
            }
        }
        break;
    case CMD_SET_MAIN_SCREEN_SETTING:
        packet >> main_screen_setting;
        break;
    case CMD_SCAN_OBJECT:
        {
            int32_t id;
            packet >> id;

            P<SpaceShip> ship = game_server->getObjectById(id);
            if (ship)
            {
                scanning_ship = ship;
                scanning_delay = 6.0;
            }
        }
        break;
    case CMD_SET_SYSTEM_POWER:
        {
            ESystem system;
            float level;
            packet >> system >> level;
            if (system < SYS_COUNT && level >= 0.0 && level <= 3.0)
                systems[system].power_level = level;
        }
        break;
    case CMD_SET_SYSTEM_COOLANT:
        {
            ESystem system;
            float level;
            packet >> system >> level;
            if (system < SYS_COUNT && level >= 0.0 && level <= 10.0)
                setSystemCoolant(system, level);
        }
        break;
    case CMD_DOCK:
        {
            int32_t id;
            packet >> id;
            requestDock(game_server->getObjectById(id));
        }
        break;
    case CMD_UNDOCK:
        requestUndock();
        break;
    case CMD_OPEN_TEXT_COMM:
        if (comms_state == CS_Inactive)
        {
            int32_t id;
            packet >> id;
            comms_target = game_server->getObjectById(id);
            if (comms_target)
            {
                comms_state = CS_OpeningChannel;
                comms_open_delay = comms_channel_open_time;
            }
        }
        break;
    case CMD_CLOSE_TEXT_COMM:
        if (comms_state == CS_ChannelOpenPlayer && comms_target)
        {
            P<PlayerSpaceship> playerShip = comms_target;
            playerShip->comms_state = CS_Inactive;
        }
        comms_state = CS_Inactive;
        break;
    case CMD_SEND_TEXT_COMM:
        if (comms_state == CS_ChannelOpen && comms_target)
        {
            int8_t index;
            packet >> index;
            if (index < comms_reply_count)
            {
                comms_incomming_message = "?";
                comms_reply_count = 0;
                comms_script_interface.commChannelMessage(comms_reply[index].id);
            }
        }
        break;
    case CMD_SEND_TEXT_COMM_PLAYER:
        if (comms_state == CS_ChannelOpenPlayer)
        {
            string message;
            packet >> message;
            comms_incomming_message = comms_incomming_message + "\n<" + message;
            P<PlayerSpaceship> playership = comms_target;
            if (playership)
                playership->comms_incomming_message = playership->comms_incomming_message + "\n>" + message;
        }
        break;
    case CMD_OPEN_VOICE_COMM:
        if (comms_state == CS_ChannelOpenPlayer)
        {
            network_audio_stream.startListening(9002); //HARDCODED
            //Setup audio recorder & streamer
        }
        break;
    case CMD_CLOSE_VOICE_COMM:
        if (comms_state == CS_ChannelOpenPlayer)
        {
            //stop audio recorder & streamer
        }
        break;
    case CMD_SEND_VOICE_COMM:
        {
            std::cout << "Recieved voice chat" << std::endl;
            //Piece of voice stream recieved. Do something.
        }
        break;
    case CMD_SET_AUTO_REPAIR:
        packet >> auto_repair_enabled;
        break;
    case CMD_SET_BEAM_FREQUENCY:
        {
            int32_t new_frequency;
            packet >> new_frequency;
            beam_frequency = new_frequency;
            if (beam_frequency < 0)
                beam_frequency = 0;
            if (beam_frequency > SpaceShip::max_frequency)
                beam_frequency = SpaceShip::max_frequency;
        }
        break;
    case CMD_SET_SHIELD_FREQUENCY:
        if (shield_calibration_delay <= 0.0)
        {
            int32_t new_frequency;
            packet >> new_frequency;
            if (new_frequency != shield_frequency)
            {
                shield_frequency = new_frequency;
                shield_calibration_delay = shield_calibration_time;
                shields_active = false;
                if (shield_frequency < 0)
                    shield_frequency = 0;
                if (shield_frequency > SpaceShip::max_frequency)
                    shield_frequency = SpaceShip::max_frequency;
            }
        }
        break;
    case CMD_ADD_WAYPOINT:
        {
            sf::Vector2f position;
            packet >> position;
            if (waypoints.size() < 32)
                waypoints.push_back(position);
        }
        break;
    case CMD_REMOVE_WAYPOINT:
        {
            int32_t index;
            packet >> index;
            if (index >= 0 && index < int(waypoints.size()))
                waypoints.erase(waypoints.begin() + index);
        }
        break;
    case CMD_ACTIVATE_SELF_DESTRUCT:
        activate_self_destruct = true;
        for(int n=0; n<max_self_destruct_codes; n++)
        {
            self_destruct_code[n] = irandom(0, 999999);
            self_destruct_code_confirmed[n] = false;
            self_destruct_code_entry_position[n] = max_crew_positions;
            while(self_destruct_code_entry_position[n] == max_crew_positions)
            {
                self_destruct_code_entry_position[n] = ECrewPosition(irandom(0, commsOfficer));
                for(int i=0; i<n; i++)
                    if (self_destruct_code_entry_position[n] == self_destruct_code_entry_position[i])
                        self_destruct_code_entry_position[n] = max_crew_positions;
            }
            self_destruct_code_show_position[n] = max_crew_positions;
            while(self_destruct_code_show_position[n] == max_crew_positions)
            {
                self_destruct_code_show_position[n] = ECrewPosition(irandom(0, commsOfficer));
                if (self_destruct_code_show_position[n] == self_destruct_code_entry_position[n])
                    self_destruct_code_show_position[n] = max_crew_positions;
                for(int i=0; i<n; i++)
                    if (self_destruct_code_show_position[n] == self_destruct_code_show_position[i])
                        self_destruct_code_show_position[n] = max_crew_positions;
            }
        }
        break;
    case CMD_CANCEL_SELF_DESTRUCT:
        activate_self_destruct = false;
        break;
    case CMD_CONFIRM_SELF_DESTRUCT:
        {
            int8_t index;
            uint32_t code;
            packet >> index >> code;
            if (index >= 0 && index < max_self_destruct_codes && self_destruct_code[index] == code)
                self_destruct_code_confirmed[index] = true;
        }
        break;
    }
}

void PlayerSpaceship::commandTargetRotation(float target)
{
    sf::Packet packet;
    packet << CMD_TARGET_ROTATION << target;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandImpulse(float target)
{
    sf::Packet packet;
    packet << CMD_IMPULSE << target;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandWarp(int8_t target)
{
    sf::Packet packet;
    packet << CMD_WARP << target;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandJump(float distance)
{
    sf::Packet packet;
    packet << CMD_JUMP << distance;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetTarget(P<SpaceObject> target)
{
    sf::Packet packet;
    if (target)
        packet << CMD_SET_TARGET << target->getMultiplayerId();
    else
        packet << CMD_SET_TARGET << int32_t(-1);
    sendClientCommand(packet);
}

void PlayerSpaceship::commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType)
{
    sf::Packet packet;
    packet << CMD_LOAD_TUBE << tubeNumber << missileType;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandUnloadTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_UNLOAD_TUBE << tubeNumber;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandFireTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_FIRE_TUBE << tubeNumber;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetShields(bool enabled)
{
    sf::Packet packet;
    packet << CMD_SET_SHIELDS << enabled;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandMainScreenSetting(EMainScreenSetting mainScreen)
{
    sf::Packet packet;
    packet << CMD_SET_MAIN_SCREEN_SETTING << mainScreen;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandScan(P<SpaceObject> object)
{
    sf::Packet packet;
    packet << CMD_SCAN_OBJECT << object->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemPower(ESystem system, float power_level)
{
    sf::Packet packet;
    packet << CMD_SET_SYSTEM_POWER << system << power_level;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemCoolant(ESystem system, float coolant_level)
{
    sf::Packet packet;
    packet << CMD_SET_SYSTEM_COOLANT << system << coolant_level;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandDock(P<SpaceObject> object)
{
    if (!object) return;
    sf::Packet packet;
    packet << CMD_DOCK << object->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandUndock()
{
    sf::Packet packet;
    packet << CMD_UNDOCK;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandOpenTextComm(P<SpaceObject> obj)
{
    if (!obj) return;
    sf::Packet packet;
    packet << CMD_OPEN_TEXT_COMM << obj->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandOpenVoiceComm(P<SpaceObject> obj)
{
    if(!obj) return;
    sf::Packet packet;
    packet << CMD_OPEN_VOICE_COMM << obj->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCloseVoiceComm()
{
    sf::Packet packet;
    packet << CMD_CLOSE_VOICE_COMM;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCloseTextComm()
{
    sf::Packet packet;
    packet << CMD_CLOSE_TEXT_COMM;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSendComm(int8_t index)
{
    sf::Packet packet;
    packet << CMD_SEND_TEXT_COMM << index;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSendCommPlayer(string message)
{
    sf::Packet packet;
    packet << CMD_SEND_TEXT_COMM_PLAYER << message;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetAutoRepair(bool enabled)
{
    sf::Packet packet;
    packet << CMD_SET_AUTO_REPAIR << enabled;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetBeamFrequency(int32_t frequency)
{
    sf::Packet packet;
    packet << CMD_SET_BEAM_FREQUENCY << frequency;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetShieldFrequency(int32_t frequency)
{
    sf::Packet packet;
    packet << CMD_SET_SHIELD_FREQUENCY << frequency;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandAddWaypoint(sf::Vector2f position)
{
    sf::Packet packet;
    packet << CMD_ADD_WAYPOINT << position;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandRemoveWaypoint(int32_t index)
{
    sf::Packet packet;
    packet << CMD_REMOVE_WAYPOINT << index;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandActivateSelfDestruct()
{
    sf::Packet packet;
    packet << CMD_ACTIVATE_SELF_DESTRUCT;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCancelSelfDestruct()
{
    sf::Packet packet;
    packet << CMD_CANCEL_SELF_DESTRUCT;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandConfirmDestructCode(int8_t index, uint32_t code)
{
    sf::Packet packet;
    packet << CMD_CONFIRM_SELF_DESTRUCT << index << code;
    sendClientCommand(packet);
}
