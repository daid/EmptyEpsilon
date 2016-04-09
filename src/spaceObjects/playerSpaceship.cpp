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
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getAlertLevel);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setShieldsActive);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, addToShipLog);

    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsInactive);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsOpening);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsBeingHailed);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsBeingHailedByGM);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsFailed);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsBroken);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsClosed);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsChatOpen);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsChatOpenToGM);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsChatOpenToPlayer);
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsScriptOpen);

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
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAbortDock);
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
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetScienceLink);
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
static const int16_t CMD_SCAN_DONE = 0x000C;
static const int16_t CMD_SCAN_CANCEL = 0x000D;
static const int16_t CMD_SET_SYSTEM_POWER = 0x000E;
static const int16_t CMD_SET_SYSTEM_COOLANT = 0x000F;
static const int16_t CMD_DOCK = 0x0010;
static const int16_t CMD_UNDOCK = 0x0011;
static const int16_t CMD_OPEN_TEXT_COMM = 0x0012; //TEXT communication
static const int16_t CMD_CLOSE_TEXT_COMM = 0x0013;
static const int16_t CMD_SEND_TEXT_COMM = 0x0014;
static const int16_t CMD_SEND_TEXT_COMM_PLAYER = 0x0015;
static const int16_t CMD_ANSWER_COMM_HAIL = 0x0016;
static const int16_t CMD_SET_AUTO_REPAIR = 0x0017;
static const int16_t CMD_SET_BEAM_FREQUENCY = 0x0018;
static const int16_t CMD_SET_BEAM_SYSTEM_TARGET = 0x0019;
static const int16_t CMD_SET_SHIELD_FREQUENCY = 0x001A;
static const int16_t CMD_ADD_WAYPOINT = 0x001B;
static const int16_t CMD_REMOVE_WAYPOINT = 0x001C;
static const int16_t CMD_ACTIVATE_SELF_DESTRUCT = 0x001D;
static const int16_t CMD_CANCEL_SELF_DESTRUCT = 0x001E;
static const int16_t CMD_CONFIRM_SELF_DESTRUCT = 0x001F;
static const int16_t CMD_COMBAT_MANEUVER_BOOST = 0x0020;
static const int16_t CMD_COMBAT_MANEUVER_STRAFE = 0x0021;
static const int16_t CMD_LAUNCH_PROBE = 0x0022;
static const int16_t CMD_SET_ALERT_LEVEL = 0x0023;
static const int16_t CMD_SET_SCIENCE_LINK = 0x0024;
static const int16_t CMD_ABORT_DOCK = 0x0025;

template<> int convert<EAlertLevel>::returnType(lua_State* L, EAlertLevel l)
{
    lua_pushstring(L, alertLevelToString(l).c_str());
    return 1;
}

string alertLevelToString(EAlertLevel level)
{
    switch(level)
    {
    case AL_RedAlert: return "RED ALERT";
    case AL_YellowAlert: return "YELLOW ALERT";
    case AL_Normal: return "Normal";
    default:
        return "???";
    }
}

static inline sf::Packet& operator << (sf::Packet& packet, const PlayerSpaceship::ShipLogEntry& e) { return packet << e.prefix << e.text << e.color.r << e.color.g << e.color.b << e.color.a; }
static inline sf::Packet& operator >> (sf::Packet& packet, PlayerSpaceship::ShipLogEntry& e) { packet >> e.prefix >> e.text >> e.color.r >> e.color.g >> e.color.b >> e.color.a; return packet; }

REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");
PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship", 5000)
{
    main_screen_setting = MSS_Front;
    hull_damage_indicator = 0.0;
    jump_indicator = 0.0;
    comms_state = CS_Inactive;
    comms_open_delay = 0.0;
    shield_calibration_delay = 0.0;
    auto_repair_enabled = false;
    activate_self_destruct = false;
    self_destruct_countdown = 0.0;
    scanning_delay = 0.0;
    scanning_complexity = 0;
    scanning_depth = 0;
    scan_probe_stock = max_scan_probes;
    scan_probe_recharge = 0.0;
    alert_level = AL_Normal;
    shields_active = false;

    setFactionId(1);

    //For now, set players to always been known to all other factions.
    for(unsigned int faction_id=0; faction_id<factionInfo.size(); faction_id++)
        setScannedStateForFaction(faction_id, SS_FullScan);

    updateMemberReplicationUpdateDelay(&target_rotation, 0.1);
    registerMemberReplication(&hull_damage_indicator, 0.5);
    registerMemberReplication(&hull_strength, 0.5);
    registerMemberReplication(&hull_max);
    registerMemberReplication(&jump_indicator, 0.5);
    registerMemberReplication(&energy_level, 0.1);
    registerMemberReplication(&max_energy_level);
    registerMemberReplication(&main_screen_setting);
    registerMemberReplication(&scanning_delay, 0.5);
    registerMemberReplication(&scanning_complexity);
    registerMemberReplication(&scanning_depth);
    registerMemberReplication(&shields_active);
    registerMemberReplication(&shield_calibration_delay, 0.5);
    registerMemberReplication(&auto_repair_enabled);
    registerMemberReplication(&beam_system_target);
    registerMemberReplication(&comms_state);
    registerMemberReplication(&comms_open_delay, 1.0);
    registerMemberReplication(&comms_reply_message);
    registerMemberReplication(&comms_target_name);
    registerMemberReplication(&comms_incomming_message);
    registerMemberReplication(&ships_log);
    registerMemberReplication(&waypoints);
    registerMemberReplication(&scan_probe_stock);
    registerMemberReplication(&activate_self_destruct);
    registerMemberReplication(&self_destruct_countdown, 0.2);
    registerMemberReplication(&alert_level);
    registerMemberReplication(&linked_object);
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

    setCallSign("PL" + string(getMultiplayerId()));

    addToShipLog("Start of log", sf::Color::White);
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
        P<SpaceShip> docked_with_ship = docking_target;
        if (!docked_with_ship || docked_with_ship->useEnergy(delta * 10.0))
            energy_level += delta * 10.0;
        if (!docked_with_ship)  //Only recharge probes and hull when we are not docked to a ship (and thus a station). Bit hackish for now.
        {
            if (scan_probe_stock < max_scan_probes)
            {
                scan_probe_recharge += delta;
                if (scan_probe_recharge > scan_probe_charge_time)
                {
                    scan_probe_stock += 1;
                    scan_probe_recharge = 0.0;
                }
            }
            if (hull_strength < hull_max)
            {
                hull_strength += delta;
                if (hull_strength > hull_max)
                    hull_strength = hull_max;
            }
        }
    }else{
        scan_probe_recharge = 0.0;
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

                        if (playerShip->comms_state == CS_Inactive || playerShip->comms_state == CS_ChannelFailed || playerShip->comms_state == CS_ChannelBroken || playerShip->comms_state == CS_ChannelClosed)
                        {
                            playerShip->comms_state = CS_BeingHailed;
                            playerShip->comms_target = this;
                            playerShip->comms_target_name = getCallSign();
                        }
                    }else{
                        if (comms_script_interface.openCommChannel(this, comms_target))
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

            addHeat(ESystem(n), delta * systems[n].getHeatingDelta() * system_heatup_per_second);
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
            if (!useEnergy(energy_warp_per_second * delta * powf(warp_request, 1.2f) * (shields_active ? 1.5 : 1.0)))
                warp_request = 0;
        }
        if (scanning_target)
        {
            if (scanning_complexity < 1)
            {
                scanning_delay -= delta;
                if (scanning_delay < 0)
                {
                    scanning_target->scannedBy(this);
                    scanning_target = NULL;
                }
            }
        }else{
            scanning_delay = 0.0;
        }

        if (activate_self_destruct)
        {
            if (self_destruct_countdown <= 0.0)
            {
                bool do_self_destruct = true;
                for(int n=0; n<max_self_destruct_codes; n++)
                    if (!self_destruct_code_confirmed[n])
                        do_self_destruct = false;
                if (do_self_destruct)
                {
                    self_destruct_countdown = 10.0f;
                }
            }else{
                self_destruct_countdown -= delta;
                if (self_destruct_countdown <= 0.0)
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
        }
    }else{
        //Client side
        if (scanning_complexity < 1)
        {
            if (scanning_delay > 0.0)
                scanning_delay -= delta;
        }
        if (comms_open_delay > 0)
            comms_open_delay -= delta;
    }

    addHeat(SYS_Impulse, combat_maneuver_boost_active * delta * heat_per_combat_maneuver_boost);
    addHeat(SYS_Maneuver, fabs(combat_maneuver_strafe_active) * delta * heat_per_combat_maneuver_strafe);
    addHeat(SYS_Warp, current_warp * delta * heat_per_warp);

    SpaceShip::update(delta);

    if (energy_level > max_energy_level)
        energy_level = max_energy_level;
}

void PlayerSpaceship::applyTemplateValues()
{
    SpaceShip::applyTemplateValues();

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
    jump_indicator = 2.0;
    SpaceShip::executeJump(distance);
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

bool PlayerSpaceship::useEnergy(float amount)
{
    if (energy_level >= amount)
    {
        energy_level -= amount;
        return true;
    }
    return false;
}

void PlayerSpaceship::addHeat(ESystem system, float amount)
{
    if (!hasSystem(system)) return;

    systems[system].heat_level += amount;
    if (systems[system].heat_level > 1.0)
    {
        float overheat = systems[system].heat_level - 1.0;
        systems[system].heat_level = 1.0;
        if (gameGlobalInfo->use_system_damage)
        {
            // As heat damage is specified as damage per second on overheating, we need to calculate the amount of overheat back to a time
            // and use that to calculate the actual damage.
            systems[system].health -= overheat / system_heatup_per_second * damage_per_second_on_overheat;
            if (systems[system].health < -1.0)
                systems[system].health = -1.0;
        }
    }
    if (systems[system].heat_level < 0.0)
        systems[system].heat_level = 0.0;
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

void PlayerSpaceship::addToShipLog(string message, sf::Color color)
{
    if (ships_log.size() > 100)
        ships_log.erase(ships_log.begin());
    ships_log.emplace_back(string(engine->getElapsedTime(), 1) + string(": "), message, color);
}

const std::vector<PlayerSpaceship::ShipLogEntry>& PlayerSpaceship::getShipsLog() const
{
    return ships_log;
}

void PlayerSpaceship::setCommsMessage(string message)
{
    for(string line : message.split("\n"))
        addToShipLog(line, sf::Color(192, 192, 255));
    comms_incomming_message = message;
}

void PlayerSpaceship::addCommsIncommingMessage(string message)
{
    for(string line : message.split("\n"))
        addToShipLog(line, sf::Color(192, 192, 255));
    comms_incomming_message = comms_incomming_message + "\n> " + message;
}

void PlayerSpaceship::addCommsOutgoingMessage(string message)
{
    for(string line : message.split("\n"))
        addToShipLog(line, sf::Color(192, 255, 192));
    comms_incomming_message = comms_incomming_message + "\n< " + message;
}

void PlayerSpaceship::addCommsReply(int32_t id, string message)
{
    if (comms_reply_id.size() >= 200)
        return;
    comms_reply_id.push_back(id);
    comms_reply_message.push_back(message);
}

bool PlayerSpaceship::hailCommsByGM(string target_name)
{
    if (!isCommsInactive() && !isCommsFailed() && !isCommsBroken() && !isCommsClosed())
        return false;

    addToShipLog("Hailed by " + target_name, sf::Color::White);
    comms_state = CS_BeingHailedByGM;
    comms_target_name = target_name;
    comms_target = nullptr;
    return true;
}

bool PlayerSpaceship::hailByObject(P<SpaceObject> object, string opening_message)
{
    if (isCommsOpening() || isCommsBeingHailed())
    {
        if (comms_target != object)
            return false;
    }
    if (isCommsBeingHailedByGM())
    {
        return false;
    }
    if (isCommsChatOpen() || isCommsScriptOpen())
    {
        return false;
    }

    comms_target = object;
    comms_target_name = object->getCallSign();
    comms_state = CS_BeingHailed;
    comms_incomming_message = opening_message;
    return true;
}

void PlayerSpaceship::closeComms()
{
    if (comms_state != CS_Inactive)
    {
        if (comms_state == CS_ChannelOpenPlayer && comms_target)
        {
            P<PlayerSpaceship> player_ship = comms_target;
            player_ship->comms_state = CS_ChannelClosed;
            player_ship->addToShipLog("Communication channel closed by other side", sf::Color::White);
        }
        if (comms_state == CS_OpeningChannel && comms_target)
        {
            P<PlayerSpaceship> player_ship = comms_target;
            if (player_ship)
            {
                if (player_ship->comms_state == CS_BeingHailed && player_ship->comms_target == this)
                {
                    player_ship->comms_state = CS_Inactive;
                    player_ship->addToShipLog("Hailing from " + getCallSign() + " stopped", sf::Color::White);
                }
            }
        }
        addToShipLog("Communication channel closed", sf::Color::White);
        if (comms_state == CS_ChannelOpenGM)
            comms_state = CS_ChannelClosed;
        else
            comms_state = CS_Inactive;
    }
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
            int8_t tube_nr;
            EMissileWeapons type;
            packet >> tube_nr >> type;

            if (tube_nr >= 0 && tube_nr < max_weapon_tubes)
                weapon_tube[tube_nr].startLoad(type);
        }
        break;
    case CMD_UNLOAD_TUBE:
        {
            int8_t tube_nr;
            packet >> tube_nr;

            if (tube_nr >= 0 && tube_nr < max_weapon_tubes)
            {
                weapon_tube[tube_nr].startUnload();
            }
        }
        break;
    case CMD_FIRE_TUBE:
        {
            int8_t tube_nr;
            float missile_target_angle;
            packet >> tube_nr >> missile_target_angle;

            if (tube_nr >= 0 && tube_nr < max_weapon_tubes)
                weapon_tube[tube_nr].fire(missile_target_angle);
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

            P<SpaceObject> obj = game_server->getObjectById(id);
            if (obj)
            {
                scanning_target = obj;
                scanning_complexity = obj->scanningComplexity(this);
                scanning_depth = obj->scanningChannelDepth(this);
                scanning_delay = max_scanning_delay;
            }
        }
        break;
    case CMD_SCAN_DONE:
        if (scanning_target && scanning_complexity > 0)
        {
            scanning_target->scannedBy(this);
            scanning_target = nullptr;
        }
        break;
    case CMD_SCAN_CANCEL:
        if (scanning_target && scanning_complexity > 0)
        {
            scanning_target = nullptr;
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
    case CMD_ABORT_DOCK:
        abortDock();
        break;
    case CMD_OPEN_TEXT_COMM:
        if (comms_state == CS_Inactive || comms_state == CS_BeingHailed || comms_state == CS_BeingHailedByGM || comms_state == CS_ChannelClosed)
        {
            int32_t id;
            packet >> id;
            comms_target = game_server->getObjectById(id);
            if (comms_target)
            {
                P<PlayerSpaceship> player = comms_target;
                comms_state = CS_OpeningChannel;
                comms_open_delay = comms_channel_open_time;
                addToShipLog("Hailing: " + comms_target->getCallSign(), sf::Color::White);
            }else{
                comms_state = CS_Inactive;
            }
        }
        break;
    case CMD_CLOSE_TEXT_COMM:
        closeComms();
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
                    addToShipLog("Opened communication channel to " + playerShip->getCallSign(), sf::Color::White);
                    playerShip->addToShipLog("Opened communication channel to " + getCallSign(), sf::Color::White);
                }else{
                    addToShipLog("Refused communications from " + playerShip->getCallSign(), sf::Color::White);
                    playerShip->addToShipLog("Refused communications to " + getCallSign(), sf::Color::White);
                    comms_state = CS_Inactive;
                    playerShip->comms_state = CS_ChannelFailed;
                }
            }else{
                if (anwser)
                {
                    if (!comms_target)
                    {
                        addToShipLog("Hail suddenly went dead.", sf::Color::Red);
                        comms_state = CS_ChannelBroken;
                    }else{
                        addToShipLog("Accepted hail from " + comms_target->getCallSign(), sf::Color::White);
                        comms_reply_id.clear();
                        comms_reply_message.clear();
                        if (comms_incomming_message == "")
                        {
                            if (comms_script_interface.openCommChannel(this, comms_target))
                                comms_state = CS_ChannelOpen;
                            else
                                comms_state = CS_ChannelFailed;
                        }else{
                            //Set the comms message again, so it ends up in the log.
                            // as the comms_incomming_message was set by "hailByObject", without ending up in the log.
                            setCommsMessage(comms_incomming_message);
                            comms_state = CS_ChannelOpen;
                        }
                    }
                }else{
                    if (comms_target)
                        addToShipLog("Refused hail from " + comms_target->getCallSign(), sf::Color::White);
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

                addToShipLog("Opened communication channel to " + comms_target_name, sf::Color::White);
                comms_incomming_message = "Opened comms";
            }else{
                addToShipLog("Refused hail from " + comms_target_name, sf::Color::Red);
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
                addToShipLog(comms_reply_message[index], sf::Color(192, 255, 192));

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

            addCommsOutgoingMessage(message);
            P<PlayerSpaceship> playership = comms_target;
            if (comms_state == CS_ChannelOpenPlayer && playership)
                playership->addCommsIncommingMessage(message);
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
        if (self_destruct_countdown <= 0.0f)
        {
            activate_self_destruct = false;
        }
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
    case CMD_SET_ALERT_LEVEL:
        {
            packet >> alert_level;
        }
        break;
    case CMD_SET_SCIENCE_LINK:
        {
            packet >> linked_object;
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

void PlayerSpaceship::commandAbortDock()
{
    sf::Packet packet;
    packet << CMD_ABORT_DOCK;
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

void PlayerSpaceship::commandScanDone()
{
    sf::Packet packet;
    packet << CMD_SCAN_DONE;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandScanCancel()
{
    sf::Packet packet;
    packet << CMD_SCAN_CANCEL;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetAlertLevel(EAlertLevel level)
{
    sf::Packet packet;
    packet << CMD_SET_ALERT_LEVEL;
    packet << level;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetScienceLink(int32_t id){
    sf::Packet packet;
    packet << CMD_SET_SCIENCE_LINK << id;
    sendClientCommand(packet);
}

string PlayerSpaceship::getExportLine()
{
    return "PlayerSpaceship():setTemplate(\"" + template_name + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + getScriptExportModificationsOnTemplate();;
}
