#include "playerSpaceship.h"
#include "scanProbe.h"
#include "repairCrew.h"
#include "explosionEffect.h"
#include "gameGlobalInfo.h"
#include "main.h"

#include "scriptInterface.h"

/// PlayerSpaceship are the ships that are controlled by the player.
REGISTER_SCRIPT_SUBCLASS(PlayerSpaceship, SpaceShip)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getWaypoint);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getWaypointCount);

    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandTargetRotation);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandImpulse);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandWarp);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandJump);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandLoadTube);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandUnloadTube);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandFireTube);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetShields);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMainScreenSetting);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandScan);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetSystemPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetSystemCoolant);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandDock);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandUndock);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandOpenTextComm);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCloseTextComm);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAnswerCommHail);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSendComm);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSendCommPlayer);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetAutoRepair);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetBeamFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetBeamSystemTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetShieldFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAddWaypoint);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandRemoveWaypoint);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandActivateSelfDestruct);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCancelSelfDestruct);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandConfirmDestructCode);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCombatManeuverBoost);
}

static float system_power_user_factor[] = {
    /*SYS_Reactor*/ -25.0,
    /*SYS_BeamWeapons*/ 3.0,
    /*SYS_MissileSystem*/ 1.0,
    /*SYS_Maneuver*/ 2.0,
    /*SYS_Impulse*/ 4.0,
    /*SYS_Warp*/ 5.0,
    /*SYS_JumpDrive*/ 5.0,
    /*SYS_FrontShield*/ 5.0,
    /*SYS_RearShield*/ 5.0,
};

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
static const int16_t CMD_ANSWER_COMM_HAIL = 0x0014;
static const int16_t CMD_SET_AUTO_REPAIR = 0x0016;
static const int16_t CMD_SET_BEAM_FREQUENCY = 0x0017;
static const int16_t CMD_SET_BEAM_SYSTEM_TARGET = 0x0018;
static const int16_t CMD_SET_SHIELD_FREQUENCY = 0x0019;
static const int16_t CMD_ADD_WAYPOINT = 0x001A;
static const int16_t CMD_REMOVE_WAYPOINT = 0x001B;
static const int16_t CMD_ACTIVATE_SELF_DESTRUCT = 0x001C;
static const int16_t CMD_CANCEL_SELF_DESTRUCT = 0x001D;
static const int16_t CMD_CONFIRM_SELF_DESTRUCT = 0x001E;
static const int16_t CMD_COMBAT_MANEUVER_BOOST = 0x001F;
static const int16_t CMD_COMBAT_MANEUVER_STRAFE = 0x0020;
static const int16_t CMD_LAUNCH_PROBE = 0x0021;

REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");

PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship", 5000)
{
    energy_level = 1000;
    main_screen_setting = MSS_Front;
    hull_damage_indicator = 0.0;
    jump_indicator = 0.0;
    scanned_by_player = SS_FullScan;
    comms_state = CS_Inactive;
    comms_open_delay = 0.0;
    shield_calibration_delay = 0.0;
    auto_repair_enabled = false;
    activate_self_destruct = false;
    scanning_delay = 0.0;
    scan_probe_stock = max_scan_probes;

    setFactionId(1);

    updateMemberReplicationUpdateDelay(&target_rotation, 0.1);
    registerMemberReplication(&hull_damage_indicator, 0.5);
    registerMemberReplication(&hull_strength, 0.5);
    registerMemberReplication(&hull_max);
    registerMemberReplication(&jump_indicator, 0.5);
    registerMemberReplication(&energy_level);
    registerMemberReplication(&main_screen_setting);
    registerMemberReplication(&scanning_delay, 0.5);
    registerMemberReplication(&shields_active);
    registerMemberReplication(&shield_calibration_delay, 0.5);
    registerMemberReplication(&auto_repair_enabled);
    registerMemberReplication(&beam_system_target);
    registerMemberReplication(&comms_state);
    registerMemberReplication(&comms_open_delay, 1.0);
    registerMemberReplication(&comms_reply_message);
    registerMemberReplication(&comms_target_name);
    registerMemberReplication(&comms_incomming_message);
    registerMemberReplication(&waypoints);
    registerMemberReplication(&scan_probe_stock);
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

        registerMemberReplication(&systems[n].power_level);
        registerMemberReplication(&systems[n].coolant_level);
        registerMemberReplication(&systems[n].heat_level, 1.0);
    }

    if (game_server && gameGlobalInfo->use_system_damage)
    {
        for(int n=0; n<3; n++)
        {
            P<RepairCrew> rc = new RepairCrew();
            rc->ship_id = getMultiplayerId();
        }
    }

    if (game_server)
    {
        if (gameGlobalInfo->insertPlayerShip(this) < 0)
        {
            destroy();
        }
    }
}

void PlayerSpaceship::update(float delta)
{
    if (hull_damage_indicator > 0)
        hull_damage_indicator -= delta;
    if (jump_indicator > 0)
        jump_indicator -= delta;

    if (shield_calibration_delay > 0)
    {
        shield_calibration_delay -= delta * (getSystemEffectiveness(SYS_FrontShield) + getSystemEffectiveness(SYS_RearShield)) / 2.0;
    }

    if (docking_state == DS_Docked)
    {
        scan_probe_stock = max_scan_probes;
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
                if (!comms_target)
                {
                    comms_state = CS_ChannelBroken;
                }else{
                    comms_reply_id.clear();
                    comms_reply_message.clear();
                    P<PlayerSpaceship> playerShip = comms_target;
                    if (playerShip)
                    {
                        comms_open_delay = PlayerSpaceship::comms_channel_open_time;

                        if (playerShip->comms_state == CS_Inactive || playerShip->comms_state == CS_ChannelFailed || playerShip->comms_state == CS_ChannelBroken)
                        {
                            playerShip->comms_state = CS_BeingHailed;
                            playerShip->comms_target = this;
                            playerShip->comms_target_name = getCallSign();
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
            if (!comms_target)
                comms_state = CS_ChannelBroken;
        }

        if (shields_active)
            useEnergy(delta * energy_shield_use_per_second);

        energy_level += delta * getNetPowerUsage() * 0.05;
        for(int n=0; n<SYS_COUNT; n++)
        {
            if (!hasSystem(ESystem(n))) continue;

            systems[n].heat_level += delta * systems[n].getHeatingDelta() * system_heatup_per_second;
            if (systems[n].heat_level > 1.0)
            {
                systems[n].heat_level = 1.0;
                if (gameGlobalInfo->use_system_damage)
                {
                    systems[n].health -= delta * damage_per_second_on_overheat;
                    if (systems[n].health < -1.0)
                        systems[n].health = -1.0;
                }
            }
            if (systems[n].heat_level < 0.0)
                systems[n].heat_level = 0.0;
        }

        if (systems[SYS_Reactor].health < -0.9 && systems[SYS_Reactor].heat_level == 1.0)
        {
            //Ok, you screwed up. Seriously, your reactor is heavy damaged and overheated. So it will explode.
            ExplosionEffect* e = new ExplosionEffect();
            e->setSize(1000.0f);
            e->setPosition(getPosition());

            DamageInfo info(this, DT_Kinetic, getPosition());
            SpaceObject::damageArea(getPosition(), 500, 30, 60, info, 0.0);

            destroy();
            return;
        }

        if (energy_level < 0.0)
            energy_level = 0.0;
        if (energy_level < 10.0)
        {
            //Out of energy, we do not care how much power you put into systems, everything is bad now.
            shields_active = false;
        }

        if (has_warp_drive && warp_request > 0 && !(has_jump_drive && jump_delay > 0))
        {
            if (!useEnergy(energy_warp_per_second * delta * float(warp_request * warp_request) * (shields_active ? 1.5 : 1.0)))
                warp_request = 0;
        }
        if (scanning_ship)
        {
            scanning_delay -= delta;
            if (scanning_delay < 0)
            {
                switch(scanning_ship->scanned_by_player)
                {
                case SS_NotScanned:
                case SS_FriendOrFoeIdentified:
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

                DamageInfo info(this, DT_Kinetic, getPosition());
                SpaceObject::damageArea(getPosition(), 1500, 100, 200, info, 0.0);

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
    
    addHeat(SYS_Impulse, combat_maneuver_boost_active * delta * heat_per_combat_maneuver_boost);
    addHeat(SYS_Maneuver, fabs(combat_maneuver_strafe_active) * delta * heat_per_combat_maneuver_strafe);
    addHeat(SYS_Warp, current_warp * delta * heat_per_warp);

    SpaceShip::update(delta);

    if (energy_level > 1000.0)
        energy_level = 1000.0;
}

void PlayerSpaceship::setShipTemplate(string template_name)
{
    SpaceShip::setShipTemplate(template_name);

    switch(gameGlobalInfo->player_warp_jump_drive_setting)
    {
    default:
        break;
    case PWJ_WarpDrive:
        setWarpDrive(true);
        setJumpDrive(false);
        break;
    case PWJ_JumpDrive:
        setWarpDrive(false);
        setJumpDrive(true);
        break;
    case PWJ_WarpAndJumpDrive:
        setWarpDrive(true);
        setJumpDrive(true);
        break;
    }
}

void PlayerSpaceship::executeJump(float distance)
{
    if (useEnergy(distance * energy_per_jump_km * (shields_active ? 3.0 : 1.0)) && systems[SYS_JumpDrive].health > 0.0)
    {
        jump_indicator = 2.0;
        SpaceShip::executeJump(distance);
        addHeat(SYS_JumpDrive, heat_per_jump);
    }
}

void PlayerSpaceship::fireBeamWeapon(int idx, P<SpaceObject> target)
{
    if (useEnergy(energy_per_beam_fire))
    {
        SpaceShip::fireBeamWeapon(idx, target);
        addHeat(SYS_BeamWeapons, heat_per_beam_fire);
    }
}

void PlayerSpaceship::takeHullDamage(float damage_amount, DamageInfo& info)
{
    if (info.type != DT_EMP)
    {
        hull_damage_indicator = 1.5;
    }
    SpaceShip::takeHullDamage(damage_amount, info);
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

void PlayerSpaceship::addHeat(ESystem system, float amount)
{
    if (!hasSystem(system)) return;
    systems[system].heat_level = std::min(1.0f, systems[system].heat_level + amount);
}

float PlayerSpaceship::getNetPowerUsage()
{
    float net_power = 0.0;
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (!hasSystem(ESystem(n))) continue;
        if (system_power_user_factor[n] < 0) //When we generate power, use the health of this system in the equation
        {
            float f = getSystemEffectiveness(ESystem(n));
            if (f > 1.0f)
                f = (1.0f + f) / 2.0f;
            net_power -= system_power_user_factor[n] * f;
        }
        else
        {
            net_power -= system_power_user_factor[n] * systems[n].power_level;
        }
    }
    return net_power;
}

void PlayerSpaceship::setCommsMessage(string message)
{
    comms_incomming_message = message;
}

void PlayerSpaceship::addCommsReply(int32_t id, string message)
{
    if (comms_reply_id.size() >= 200)
        return;
    comms_reply_id.push_back(id);
    comms_reply_message.push_back(message);
}

void PlayerSpaceship::onReceiveClientCommand(int32_t client_id, sf::Packet& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_TARGET_ROTATION:
        packet >> target_rotation;
        break;
    case CMD_IMPULSE:
        packet >> impulse_request;
        break;
    case CMD_WARP:
        packet >> warp_request;
        break;
    case CMD_JUMP:
        {
            float distance;
            packet >> distance;
            initializeJump(distance);
        }
        break;
    case CMD_SET_TARGET:
        {
            packet >> target_id;
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

            if (tubeNr >= 0 && tubeNr < max_weapon_tubes && weaponTube[tubeNr].state == WTS_Loaded)
            {
                weaponTube[tubeNr].state = WTS_Unloading;
                weaponTube[tubeNr].delay = tube_load_time;
            }
        }
        break;
    case CMD_FIRE_TUBE:
        {
            int8_t tubeNr;
            float missile_target_angle;
            packet >> tubeNr >> missile_target_angle;

            fireTube(tubeNr, missile_target_angle);
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
                    soundManager->playSound("shield_up.wav");
                else
                    soundManager->playSound("shield_down.wav");
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
                scanning_delay = max_scanning_delay;
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
        if (comms_state == CS_Inactive || comms_state == CS_BeingHailed || comms_state == CS_BeingHailedByGM)
        {
            int32_t id;
            packet >> id;
            comms_target = game_server->getObjectById(id);
            if (comms_target)
            {
                P<PlayerSpaceship> player = comms_target;
                comms_state = CS_OpeningChannel;
                comms_open_delay = comms_channel_open_time;
            }else{
                comms_state = CS_Inactive;
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
    case CMD_ANSWER_COMM_HAIL:
        if (comms_state == CS_BeingHailed)
        {
            bool anwser;
            packet >> anwser;
            P<PlayerSpaceship> playerShip = comms_target;

            if (playerShip)
            {
                if (anwser)
                {
                    comms_state = CS_ChannelOpenPlayer;
                    playerShip->comms_state = CS_ChannelOpenPlayer;

                    comms_incomming_message = "Opened comms to " + playerShip->getCallSign();
                    playerShip->comms_incomming_message = "Opened comms to " + getCallSign();
                }else{
                    comms_state = CS_Inactive;
                    playerShip->comms_state = CS_ChannelFailed;
                }
            }else{
                if (anwser)
                {
                    if (!comms_target)
                    {
                        comms_state = CS_ChannelBroken;
                    }else{
                        comms_reply_id.clear();
                        comms_reply_message.clear();
                        if (comms_incomming_message == "")
                        {
                            if (comms_script_interface.openCommChannel(this, comms_target, comms_target->comms_script_name))
                                comms_state = CS_ChannelOpen;
                            else
                                comms_state = CS_ChannelFailed;
                        }else{
                            comms_state = CS_ChannelOpen;
                        }
                    }
                }else{
                    comms_state = CS_Inactive;
                }
            }
        }
        if (comms_state == CS_BeingHailedByGM)
        {
            bool anwser;
            packet >> anwser;

            if (anwser)
            {
                comms_state = CS_ChannelOpenGM;

                comms_incomming_message = "Opened comms";
            }else{
                comms_state = CS_Inactive;
            }
        }
        break;
    case CMD_SEND_TEXT_COMM:
        if (comms_state == CS_ChannelOpen && comms_target)
        {
            uint8_t index;
            packet >> index;
            if (index < comms_reply_id.size())
            {
                comms_incomming_message = "?";
                int id = comms_reply_id[index];
                comms_reply_id.clear();
                comms_reply_message.clear();
                comms_script_interface.commChannelMessage(id);
            }
        }
        break;
    case CMD_SEND_TEXT_COMM_PLAYER:
        if (comms_state == CS_ChannelOpenPlayer || comms_state == CS_ChannelOpenGM)
        {
            string message;
            packet >> message;
            comms_incomming_message = comms_incomming_message + "\n<" + message;
            P<PlayerSpaceship> playership = comms_target;
            if (comms_state == CS_ChannelOpenPlayer && playership)
                playership->comms_incomming_message = playership->comms_incomming_message + "\n>" + message;
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
    case CMD_SET_BEAM_SYSTEM_TARGET:
        {
            ESystem system;
            packet >> system;
            beam_system_target = system;
            if (beam_system_target < SYS_None)
                beam_system_target = SYS_None;
            if (beam_system_target > ESystem(int(SYS_COUNT) - 1))
                beam_system_target = ESystem(int(SYS_COUNT) - 1);
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
            self_destruct_code[n] = irandom(0, 99999);
            self_destruct_code_confirmed[n] = false;
            self_destruct_code_entry_position[n] = max_crew_positions;
            while(self_destruct_code_entry_position[n] == max_crew_positions)
            {
                self_destruct_code_entry_position[n] = ECrewPosition(irandom(0, relayOfficer));
                for(int i=0; i<n; i++)
                    if (self_destruct_code_entry_position[n] == self_destruct_code_entry_position[i])
                        self_destruct_code_entry_position[n] = max_crew_positions;
            }
            self_destruct_code_show_position[n] = max_crew_positions;
            while(self_destruct_code_show_position[n] == max_crew_positions)
            {
                self_destruct_code_show_position[n] = ECrewPosition(irandom(0, relayOfficer));
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
    case CMD_COMBAT_MANEUVER_BOOST:
        {
            float request_amount;
            packet >> request_amount;
            if (request_amount >= 0.0 && request_amount <= 1.0)
                combat_maneuver_boost_request = request_amount;
        }
        break;
    case CMD_COMBAT_MANEUVER_STRAFE:
        {
            float request_amount;
            packet >> request_amount;
            if (request_amount >= -1.0 && request_amount <= 1.0)
                combat_maneuver_strafe_request = request_amount;
        }
        break;
    case CMD_LAUNCH_PROBE:
        if (scan_probe_stock > 0)
        {
            sf::Vector2f target;
            packet >> target;
            P<ScanProbe> p = new ScanProbe();
            p->setPosition(getPosition());
            p->setTarget(target);
            p->setOwner(this);
            scan_probe_stock--;
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

void PlayerSpaceship::commandFireTube(int8_t tubeNumber, float missile_target_angle)
{
    sf::Packet packet;
    packet << CMD_FIRE_TUBE << tubeNumber << missile_target_angle;
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
    systems[system].power_level = power_level;
    packet << CMD_SET_SYSTEM_POWER << system << power_level;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemCoolant(ESystem system, float coolant_level)
{
    sf::Packet packet;
    systems[system].coolant_level = coolant_level;
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

void PlayerSpaceship::commandCloseTextComm()
{
    sf::Packet packet;
    packet << CMD_CLOSE_TEXT_COMM;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandAnswerCommHail(bool awnser)
{
    sf::Packet packet;
    packet << CMD_ANSWER_COMM_HAIL << awnser;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSendComm(uint8_t index)
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

void PlayerSpaceship::commandSetBeamSystemTarget(ESystem system)
{
    sf::Packet packet;
    packet << CMD_SET_BEAM_SYSTEM_TARGET << system;
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

void PlayerSpaceship::commandCombatManeuverBoost(float amount)
{
    combat_maneuver_boost_request = amount;
    sf::Packet packet;
    packet << CMD_COMBAT_MANEUVER_BOOST << amount;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCombatManeuverStrafe(float amount)
{
    combat_maneuver_strafe_request = amount;
    sf::Packet packet;
    packet << CMD_COMBAT_MANEUVER_STRAFE << amount;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandLaunchProbe(sf::Vector2f target_position)
{
    sf::Packet packet;
    packet << CMD_LAUNCH_PROBE << target_position;
    sendClientCommand(packet);
}
