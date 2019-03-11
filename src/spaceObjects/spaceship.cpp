#include "spaceship.h"
#include "mesh.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/beamEffect.h"
#include "factionInfo.h"
#include "spaceObjects/explosionEffect.h"
#include "particleEffect.h"
#include "spaceObjects/warpJammer.h"
#include "gameGlobalInfo.h"
#include "shipCargo.h"
#include "scanProbe.h"
#include "gui/colorConfig.h"

#include "scriptInterface.h"

REGISTER_SCRIPT_SUBCLASS_NO_CREATE(SpaceShip, ShipTemplateBasedObject)
{
    //[DEPRICATED]
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentified);
    //[DEPRICATED]
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScanned);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedBy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedBy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getShieldsFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShieldsFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getMaxEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setMaxEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamsFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHealth);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHealth);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeat);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeat);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemCoolant);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemCoolant);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getImpulseMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setImpulseMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getRotationMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRotationMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setCombatManeuver);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDriveRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasWarpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWarpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponArc);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDirection);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponTurretArc);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponTurretDirection);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponCycleTime);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDamage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponEnergyPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponHeatPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeapon);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTurret);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponEnergyPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponHeatPerFire);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setTractorBeam);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeCount);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeCount);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeLoadType);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeAllowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeDisallowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeExclusiveFor);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeDirection);
    /// Set the icon to be used for this ship on the radar.
    /// For example, ship:setRadarTrace("RadarBlip.png") will show a dot instead of an arrow for this ship.
    /// Note: Icon is only shown after scanning, before the ship is scanned it is always shown as an arrow.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRadarTrace);

    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, addBroadcast);
    // Adds a message to the ship's log. Takes a string as the message and a
    // sf::Color.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, addToShipLog);

    // Command functions
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandTargetRotation);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandImpulse);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandWarp);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandJump);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandLoadTube);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandUnloadTube);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandFireTube);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandFireTubeAtTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandDock);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandUndock);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandAbortDock);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetBeamFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetBeamSystemTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetShieldFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandCombatManeuverBoost);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetTractorBeamDirection);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetTractorBeamArc);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, commandSetTractorBeamRange);
}

// Configure ship's log packets.
static inline sf::Packet& operator << (sf::Packet& packet, const SpaceShip::ShipLogEntry& e) { return packet << e.prefix << e.text << e.color.r << e.color.g << e.color.b << e.color.a << e.station; }
static inline sf::Packet& operator >> (sf::Packet& packet, SpaceShip::ShipLogEntry& e) { packet >> e.prefix >> e.text >> e.color.r >> e.color.g >> e.color.b >> e.color.a >> e.station; return packet; }

SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
    setCollisionPhysics(true, false);

    target_rotation = getRotation();
    impulse_request = 0;
    current_impulse = 0;
    has_warp_drive = true;
    warp_request = 0.0;
    current_warp = 0.0;
    max_warp = 2.0;
    has_jump_drive = true;
    jump_drive_min_distance = 5000.0;
    jump_drive_max_distance = 50000.0;
    jump_drive_charge = jump_drive_max_distance;
    jump_distance = 0.0;
    jump_delay = 0.0;
    wormhole_alpha = 0.0;
    weapon_tube_count = 0;
    turn_speed = 10.0;
    impulse_max_speed = 600.0;
    warp_speed_per_warp_level = 1000.0;
    combat_maneuver_charge = 1.0;
    combat_maneuver_boost_request = 0.0;
    combat_maneuver_boost_active = 0.0;
    combat_maneuver_strafe_request = 0.0;
    combat_maneuver_strafe_active = 0.0;
    combat_maneuver_boost_speed = 0.0f;
    combat_maneuver_strafe_speed = 0.0f;
    target_id = -1;
    beam_frequency = irandom(0, max_frequency);
    beam_system_target = SYS_None;
    shield_frequency = irandom(0, max_frequency);
    docking_state = DS_NotDocking;
    impulse_acceleration = 20.0;
    energy_level = 1000;
    max_energy_level = 1000;
    extern_log_size = 0;
    intern_log_size = 1;

    registerMemberReplication(&target_rotation, 1.5);
    registerMemberReplication(&rotation, 1.5);
    registerMemberReplication(&impulse_request, 0.1);
    registerMemberReplication(&current_impulse, 0.5);
    registerMemberReplication(&has_warp_drive);
    registerMemberReplication(&warp_request, 0.1);
    registerMemberReplication(&current_warp, 0.1);
    registerMemberReplication(&max_warp, 0.5);
    registerMemberReplication(&has_jump_drive);
    registerMemberReplication(&jump_drive_charge, 0.5);
    registerMemberReplication(&jump_delay, 0.5);
    registerMemberReplication(&jump_drive_min_distance);
    registerMemberReplication(&jump_drive_max_distance);
    registerMemberReplication(&wormhole_alpha, 0.5);
    registerMemberReplication(&weapon_tube_count);
    registerMemberReplication(&target_id);
    registerMemberReplication(&turn_speed);
    registerMemberReplication(&impulse_max_speed);
    registerMemberReplication(&impulse_acceleration);
    registerMemberReplication(&warp_speed_per_warp_level);
    registerMemberReplication(&shield_frequency);
    registerMemberReplication(&docking_state);
    registerMemberReplication(&beam_frequency);
    registerMemberReplication(&combat_maneuver_charge, 0.5);
    registerMemberReplication(&combat_maneuver_boost_request);
    registerMemberReplication(&combat_maneuver_boost_active, 0.2);
    registerMemberReplication(&combat_maneuver_strafe_request);
    registerMemberReplication(&combat_maneuver_strafe_active, 0.2);
    registerMemberReplication(&combat_maneuver_boost_speed);
    registerMemberReplication(&combat_maneuver_strafe_speed);
    registerMemberReplication(&radar_trace);
    registerMemberReplication(&ships_log_extern);
    registerMemberReplication(&ships_log_intern);

    for(int n=0; n<SYS_COUNT; n++)
    {
        systems[n].health = 1.0;
        systems[n].power_level = 1.0;
        systems[n].power_request = 1.0;
        systems[n].coolant_level = 0.0;
        systems[n].coolant_request = 0.0;
        systems[n].heat_level = 0.0;
        systems[n].hacked_level = 0.0;

        registerMemberReplication(&systems[n].health, 0.1);
        registerMemberReplication(&systems[n].hacked_level, 0.1);
    }

    for(int n = 0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].setParent(this);
    }

    tractor_beam.setParent(this);

    for(int n = 0; n < max_weapon_tubes; n++)
    {
        weapon_tube[n].setParent(this);
        weapon_tube[n].setIndex(n);
    }

    for(int n = 0; n < MW_Count; n++)
    {
        weapon_storage[n] = 0;
        weapon_storage_max[n] = 0;
        registerMemberReplication(&weapon_storage[n]);
        registerMemberReplication(&weapon_storage_max[n]);
    }

    for(int n = 0; n < max_docks_count; n++)
    {
        docks[n].setParent(this);
        docks[n].setIndex(n);
    }
    scanning_complexity_value = -1;
    scanning_depth_value = -1;

    setRadarSignatureInfo(0.05, 0.3, 0.3);

    if (game_server)
        setCallSign(gameGlobalInfo->getNextShipCallsign());
}

void SpaceShip::addToShipLog(string message, sf::Color color, string station)
{
    // TODO: use getShipsLog()
    if (station == "extern" && extern_log_size)
    {
        // Cap the ship's log size to 100 entries. If it exceeds that limit,
        // start erasing entries from the beginning.
        if (ships_log_extern.size() > extern_log_size)
            ships_log_extern.erase(ships_log_extern.begin());
        // Timestamp a log entry, color it, and add it to the end of the log.
        ships_log_extern.emplace_back(string(engine->getElapsedTime(), 1) + string(": "), message, color, station);
    }
    else if (station == "intern" && intern_log_size)
    {
        if (ships_log_intern.size() > intern_log_size)
            ships_log_intern.erase(ships_log_intern.begin());
        ships_log_intern.emplace_back(string(engine->getElapsedTime(), 1) + string(": "), message, color, station);
    }
}

void SpaceShip::addToShipLogBy(string message, P<SpaceObject> target)
{
    // Log messages received from other ships. Friend-or-foe colors are drawn
    // from colorConfig (colors.ini).
    if (!target)
        addToShipLog(message, colorConfig.log_receive_neutral);
    else if (isFriendly(target))
        addToShipLog(message, colorConfig.log_receive_friendly);
    else if (isEnemy(target))
        addToShipLog(message, colorConfig.log_receive_enemy);
    else
        addToShipLog(message, colorConfig.log_receive_neutral);
}

const std::vector<SpaceShip::ShipLogEntry>& SpaceShip::getShipsLog(string station) const
{
    if (station == "intern")
        return ships_log_intern;
    return ships_log_extern;
}

void SpaceShip::onReceiveClientCommand(int32_t client_id, sf::Packet& packet)
{
    // Receive a command from a client. Code in this function is executed on
    // the server only.
    int16_t command;
    packet >> command;
    handleClientCommand(client_id, command, packet);
}

void SpaceShip::handleClientCommand(int32_t client_id, int16_t command, sf::Packet& packet)
{
    switch(command)
    {
    case CMD_TARGET_ROTATION:
        packet >> target_rotation;
        break;
    case CMD_ROTATION:
        target_rotation = getRotation();
        packet >> rotation;
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
            addToShipLog("Jump Initialisation",sf::Color::White,"intern");
        }
        break;
    case CMD_SET_TARGET:
        {
            packet >> target_id;
            if (target_id != int32_t(-1))
                addToShipLog("Target activated : " + getTarget()->getCallSign(),sf::Color::Yellow,"intern");
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
            {
                weapon_tube[tube_nr].fire(missile_target_angle);
                addToShipLog("Missile fire",sf::Color::Yellow,"intern");
            }
        }
        break;
    case CMD_DOCK:
        {
            int32_t id;
            packet >> id;
            requestDock(game_server->getObjectById(id));
            addToShipLog("Docking requested",sf::Color::Cyan,"intern");
        }
        break;
    case CMD_UNDOCK:
        {
            requestUndock();
            addToShipLog("Undocking requested",sf::Color::Cyan,"intern");
        }
        break;
    case CMD_ABORT_DOCK:
        {
            abortDock();
            addToShipLog("Docking aborded",sf::Color::Cyan,"intern");
        }
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
            addToShipLog("Beam frequency changed : " + frequencyToString(new_frequency),sf::Color::Yellow,"intern");
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
            addToShipLog("Beam system target changed : " + getSystemName(system),sf::Color::Yellow,"intern");
        }
        break;
    case CMD_SET_SHIELD_FREQUENCY:
        int32_t new_frequency;
        packet >> new_frequency;
        if (new_frequency != shield_frequency)
        {
            shield_frequency = new_frequency;
            if (shield_frequency < 0)
                shield_frequency = 0;
            if (shield_frequency > SpaceShip::max_frequency)
                shield_frequency = SpaceShip::max_frequency;
            addToShipLog("Shields frequency changed : " + frequencyToString(new_frequency),sf::Color::Green,"intern");
        }
        break;
    case CMD_COMBAT_MANEUVER_BOOST:
        {
            float request_amount;
            packet >> request_amount;
            combat_maneuver_boost_request = std::min(1.0f, std::max(-1.0f, request_amount));
        }
        break;
    case CMD_COMBAT_MANEUVER_STRAFE:
        {
            float request_amount;
            packet >> request_amount;
            combat_maneuver_strafe_request = std::min(1.0f, std::max(-1.0f, request_amount));
        }
        break;
    case CMD_LAUNCH_PROBE:
        {
            sf::Vector2f target;
            packet >> target;
            P<ScanProbe> p = new ScanProbe();
            p->setPosition(getPosition());
            p->setTarget(target);
            p->setOwner(this);
        }
        break;
    case CMD_LAUNCH_CARGO:
        {
            int dockIndex;
            packet >> dockIndex;
            if (docks[dockIndex].state == EDockState::Docked 
                && docks[dockIndex].getCargo()->onLaunch(docks[dockIndex]))
            {
                docks[dockIndex].getCargo()->destroy();
                docks[dockIndex].empty();
            }
        }
        break;
    case CMD_SET_DOCK_MOVE_TARGET:
        {
            int srcIdx, destIdx;
            packet >> srcIdx >> destIdx;
            Dock& src = docks[srcIdx];
            src.setMoveTarget(destIdx);
        }
        break;
        break;
    case CMD_MOVE_CARGO:
        {
            int index;
            packet >> index;
            Dock& src = docks[index];
            src.startMoveCargo();
        }
        break;
    case CMD_CANCEL_MOVE_CARGO:
        {
            int index;
            packet >> index;
            Dock& src = docks[index];
            src.cancelMoveCargo();
        }
        break;
    case CMD_SET_DOCK_ENERGY_REQUEST:
        {
            int dockIndex;
            packet >> dockIndex;
            if (docks[dockIndex].state == EDockState::Docked && docks[dockIndex].dock_type == Dock_Energy)
            {
                float value;
                packet >> value;
                docks[dockIndex].energy_request = value;
            }
        }
        break;
    case CMD_HACKING_FINISHED:
        {
            uint32_t id;
            string target_system;
            packet >> id >> target_system;
            P<SpaceObject> obj = game_server->getObjectById(id);
            if (obj)
                obj->hackFinished(this, target_system);
        }
        break;
    case CMD_SET_TRACTOR_BEAM_DIRECTION:
        {
            float direction;
            packet >> direction;
            tractor_beam.setDirection(direction);
        }
        break;
    case CMD_SET_TRACTOR_BEAM_ARC:
        {
            float arc;
            packet >> arc;
            if (tractor_beam.getMaxArea() > 0){
                tractor_beam.setArc(arc);
                tractor_beam.setRange(std::min(tractor_beam.getRange(), tractor_beam.getMaxRange(arc)));
            }
        }
        break;
    case CMD_SET_TRACTOR_BEAM_RANGE:
        {
            float range;
            packet >> range;
            if (tractor_beam.getMaxArea() > 0){
                tractor_beam.setRange(range);
                tractor_beam.setArc(std::min(tractor_beam.getArc(), tractor_beam.getMaxArc(range)));
            }
        }
        break;
    case CMD_SET_TRACTOR_BEAM_MODE:
        {
            int mode;
            packet >> mode;
            tractor_beam.setMode(ETractorBeamMode(mode));
        }
        break;
    }
}

void SpaceShip::applyTemplateValues()
{
    for(int n=0; n<max_beam_weapons; n++)
    {
        beam_weapons[n].setPosition(ship_template->model_data->getBeamPosition(n));
        beam_weapons[n].setArc(ship_template->beams[n].getArc());
        beam_weapons[n].setDirection(ship_template->beams[n].getDirection());
        beam_weapons[n].setRange(ship_template->beams[n].getRange());
        beam_weapons[n].setTurretArc(ship_template->beams[n].getTurretArc());
        beam_weapons[n].setTurretDirection(ship_template->beams[n].getTurretDirection());
        beam_weapons[n].setTurretRotationRate(ship_template->beams[n].getTurretRotationRate());
        beam_weapons[n].setCycleTime(ship_template->beams[n].getCycleTime());
        beam_weapons[n].setDamage(ship_template->beams[n].getDamage());
        beam_weapons[n].setBeamTexture(ship_template->beams[n].getBeamTexture());
        beam_weapons[n].setEnergyPerFire(ship_template->beams[n].getEnergyPerFire());
        beam_weapons[n].setHeatPerFire(ship_template->beams[n].getHeatPerFire());
    }

    tractor_beam.setMaxArea(ship_template->tractor_beam.getMaxArea());
    tractor_beam.setDragPerSecond(ship_template->tractor_beam.getDragPerSecond());

    weapon_tube_count = ship_template->weapon_tube_count;
    energy_level = max_energy_level = ship_template->energy_storage_amount;

    impulse_max_speed = ship_template->impulse_speed;
    impulse_acceleration = ship_template->impulse_acceleration;
    turn_speed = ship_template->turn_speed;
    combat_maneuver_boost_speed = ship_template->combat_maneuver_boost_speed;
    combat_maneuver_strafe_speed = ship_template->combat_maneuver_strafe_speed;
    has_warp_drive = ship_template->warp_speed > 0.0;
    warp_speed_per_warp_level = ship_template->warp_speed;
    has_jump_drive = ship_template->has_jump_drive;
    jump_drive_min_distance = ship_template->jump_drive_min_distance;
    jump_drive_max_distance = ship_template->jump_drive_max_distance;
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].setLoadTimeConfig(ship_template->weapon_tube[n].load_time);
        weapon_tube[n].setDirection(ship_template->weapon_tube[n].direction);
        for(int m=0; m<MW_Count; m++)
        {
            if (ship_template->weapon_tube[n].type_allowed_mask & (1 << m))
                weapon_tube[n].allowLoadOf(EMissileWeapons(m));
            else
                weapon_tube[n].disallowLoadOf(EMissileWeapons(m));
        }
    }
    //shipTemplate->has_cloaking;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = weapon_storage_max[n] = ship_template->weapon_storage[n];

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);

    int droneIdx = 0;
    for (int i = 0; droneIdx < max_docks_count && i < ship_template->launcher_dock_count; i++, droneIdx++){
        docks[droneIdx].setDockType(Dock_Launcher);
    }
    for (int i = 0; droneIdx < max_docks_count && i < ship_template->energy_dock_count; i++, droneIdx++){
        docks[droneIdx].setDockType(Dock_Energy);
    }
    for (int i = 0; droneIdx < max_docks_count && i < ship_template->thermic_dock_count; i++, droneIdx++){
        docks[droneIdx].setDockType(Dock_Thermic);
    }
    for (int i = 0; droneIdx < max_docks_count && i < ship_template->repair_dock_count; i++, droneIdx++){
        docks[droneIdx].setDockType(Dock_Repair);
    }
    int maxActiveDockIndex = droneIdx;
    for (; droneIdx < max_docks_count; droneIdx++){
        docks[droneIdx].setDockType(Dock_Disabled);
    }
    for (auto &droneTemplate : ship_template->drones) // access by reference to avoid copying
    {  
        P<ShipTemplate> drone_ship_template = ShipTemplate::getTemplate(droneTemplate.template_name);
        // add drones one by one, assuming all drones are empty, and template is of drone type
        for (int i = 0; i < droneTemplate.count; i++)
        {
            Dock *dock = Dock::findOpenForDocking(docks, maxActiveDockIndex);
            if (!dock) { // no more available docks
                LOG(ERROR) << "Too many drones: " << template_name;
                break; 
            }
            P<ShipCargo> cargo = new ShipCargo(drone_ship_template);
            dock->dock(cargo);
        }
    }
}

#if FEATURE_3D_RENDERING
void SpaceShip::draw3DTransparent()
{
    if (!ship_template) return;
    ShipTemplateBasedObject::draw3DTransparent();

    if ((has_jump_drive && jump_delay > 0.0f) ||
        (wormhole_alpha > 0.0f))
    {
        float delay = jump_delay;
        if (wormhole_alpha > 0.0f)
            delay = wormhole_alpha;
        float alpha = 1.0f - (delay / 10.0f);
        model_info.renderOverlay(textureManager.getTexture("electric_sphere_texture.png"), alpha);
    }
}
#endif//FEATURE_3D_RENDERING

void SpaceShip::drawBeamOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, 
    sf::Color color, sf::Vector2f beam_position, float beam_direction, float beam_arc, float beam_range)
{
    // Set the beam's origin on radar to its relative position on the
    // mesh.
    sf::Vector2f beam_offset = sf::rotateVector(beam_position * scale, getRotation());

    // Configure an array to hold each point of the arc. Each point in
    // the array draws a line to the next point. If the color between
    // points is different, it's drawn as a gradient from the origin
    // point's color to the destination point's.
    sf::VertexArray a(sf::LinesStrip, 3);
    a[0].color = color;
    a[1].color = color;
    a[2].color = sf::Color(color.r, color.g, color.b, 0);

    // Drop the pen onto the beam's origin.
    a[0].position = beam_offset + position;

    // Draw the beam's left bound.
    a[1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beam_direction + beam_arc / 2.0f)) * beam_range * scale;
    a[2].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beam_direction + beam_arc / 2.0f)) * beam_range * scale * 1.3f;
    window.draw(a);

    // Draw the beam's right bound.
    a[1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beam_direction - beam_arc / 2.0f)) * beam_range * scale;
    a[2].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beam_direction - beam_arc / 2.0f)) * beam_range * scale * 1.3f;
    window.draw(a);

    // Draw the beam's arc.
    int arcPoints = int(beam_arc / 10) + 1;
    sf::VertexArray arc_line(sf::LinesStrip, arcPoints);
    for(int i=0; i<arcPoints; i++)
    {
        arc_line[i].color = color;
        arc_line[i].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beam_direction - beam_arc / 2.0f + 10 * i)) * beam_range * scale;
    }
    arc_line[arcPoints-1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beam_direction + beam_arc / 2.0f)) * beam_range * scale;
    window.draw(arc_line);
}

void SpaceShip::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    // Draw beam arcs on short-range radar only, and only for fully scanned
    // ships.
    if (!long_range && (!my_spaceship || (getScannedStateFor(my_spaceship) == SS_FullScan)))
    {
        // For each beam ...
        for(int n = 0; n < max_beam_weapons; n++)
        {
            // Draw beam arcs only if the beam has a range. A beam with range 0
            // effectively doesn't exist; exit if that's the case.
            if (beam_weapons[n].getRange() == 0.0) continue;

            // Color beam arcs red.
            // TODO: Make this color configurable.
            sf::Color color = sf::Color::Red;

            // If the beam is cooling down, flash and fade the arc color.
            if (beam_weapons[n].getCooldown() > 0)
                color = sf::Color(255, 255 * (beam_weapons[n].getCooldown() / beam_weapons[n].getCycleTime()), 0);

            // Initialize variables from the beam's data.
            float beam_direction = beam_weapons[n].getDirection();
            float beam_arc = beam_weapons[n].getArc();
            float beam_range = beam_weapons[n].getRange();
            sf::Vector2f beam_position = ship_template->model_data->getBeamPosition2D(n);
            drawBeamOnRadar(window, position, scale, color, beam_position, beam_direction, beam_arc, beam_range);

            // If the beam is turreted, draw the turret's arc. Otherwise, exit.
            if (beam_weapons[n].getTurretArc() == 0.0) continue;

            // Initialize variables from the turret data.
            float turret_arc = beam_weapons[n].getTurretArc();
            float turret_direction = beam_weapons[n].getTurretDirection();
            color =  sf::Color(color.r, color.g, color.b, color.a / 2);
            drawBeamOnRadar(window, position, scale, color, beam_position, turret_direction, turret_arc, beam_range);
        }

        // Draw beam arcs only if the beam has a range. A beam with range 0
        // effectively doesn't exist; exit if that's the case.
        if (tractor_beam.getMode() != TBM_Off && tractor_beam.getRange())
        {
            // TODO: Make this color configurable.
            sf::Color color = sf::Color::Cyan;
                // Initialize variables from the beam's data.
            float beam_direction = tractor_beam.getDirection();
            float beam_arc = tractor_beam.getArc();
            float beam_range = tractor_beam.getRange();
            sf::Vector2f beam_position = sf::Vector2f(0.0f, 0.0f);
            drawBeamOnRadar(window, position, scale, color, beam_position, beam_direction, beam_arc, beam_range);
        }
    }
    // If not on long-range radar ...
    if (!long_range)
    {
        // ... and the ship being drawn is either not our ship or has been
        // scanned ...
        if (!my_spaceship || getScannedStateFor(my_spaceship) >= SS_SimpleScan)
        {
            // ... draw and show shield indicators on our radar.
            drawShieldsOnRadar(window, position, scale, 1.0, true);
        } else {
            // Otherwise, draw the indicators, but don't show them.
            drawShieldsOnRadar(window, position, scale, 1.0, false);
        }
    }

    // Set up the radar sprite for objects.
    sf::Sprite objectSprite;

    // If the object is a ship that hasn't been scanned, draw the default icon.
    // Otherwise, draw the ship-specific icon.
    if (my_spaceship && (getScannedStateFor(my_spaceship) == SS_NotScanned || getScannedStateFor(my_spaceship) == SS_FriendOrFoeIdentified))
    {
        textureManager.setTexture(objectSprite, "RadarArrow.png");
    }
    else
    {
        textureManager.setTexture(objectSprite, radar_trace);
    }

    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    if (long_range)
    {
        objectSprite.setScale(0.7, 0.7);
    }
    if (my_spaceship == this)
    {
        objectSprite.setColor(sf::Color(192, 192, 255));
    }else if (my_spaceship)
    {
        if (getScannedStateFor(my_spaceship) != SS_NotScanned)
        {
            if (isEnemy(my_spaceship))
                objectSprite.setColor(sf::Color::Red);
            else if (isFriendly(my_spaceship))
                objectSprite.setColor(sf::Color(128, 255, 128));
            else
                objectSprite.setColor(sf::Color(128, 128, 255));
        }else{
            objectSprite.setColor(sf::Color(192, 192, 192));
        }
    }else{
        objectSprite.setColor(factionInfo[getFactionId()]->gm_color);
    }
    window.draw(objectSprite);
}

void SpaceShip::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (!long_range)
    {
        sf::RectangleShape bar(sf::Vector2f(60, 10));
        bar.setPosition(position.x - 30, position.y - 30);
        bar.setSize(sf::Vector2f(60 * hull_strength / hull_max, 5));
        bar.setFillColor(sf::Color(128, 255, 128, 128));
        window.draw(bar);
    }
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    if (game_server)
    {
        if (docking_state == DS_Docking)
        {
            if (!docking_target)
                docking_state = DS_NotDocking;
            else
                target_rotation = sf::vector2ToAngle(getPosition() - docking_target->getPosition());
            if (fabs(sf::angleDifference(target_rotation, getRotation())) < 10.0)
                impulse_request = -1.0;
            else
                impulse_request = 0.0;
        }
        if (docking_state == DS_Docked)
        {
            if (!docking_target)
            {
                docking_state = DS_NotDocking;
            }else{
                setPosition(docking_target->getPosition() + sf::rotateVector(docking_offset, docking_target->getRotation()));
                target_rotation = sf::vector2ToAngle(getPosition() - docking_target->getPosition());

                P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
                if (docked_with_template_based && docked_with_template_based->repair_docked)  //Check if what we are docked to allows hull repairs, and if so, do it.
                {
                    if (hull_strength < hull_max)
                    {
                        hull_strength += delta;
                        if (hull_strength > hull_max)
                            hull_strength = hull_max;
                    }
                }
            }
            impulse_request = 0.0;
        }
        if ((docking_state == DS_Docked) || (docking_state == DS_Docking))
            warp_request = 0.0;
            
        if (gameGlobalInfo->terrain.defined){
            max_warp = 2.0f + 2.0f * float(gameGlobalInfo->getTerrainPixel(getPosition()).a) / 255;
        }
    }

    float rotationDiff;
    if (rotation == 0) {
        rotationDiff = sf::angleDifference(getRotation(), target_rotation);
    } else {
        rotationDiff = rotation;
    }

    if (rotationDiff > 1.0)
        setAngularVelocity(turn_speed * getSystemEffectiveness(SYS_Maneuver));
    else if (rotationDiff < -1.0)
        setAngularVelocity(-turn_speed * getSystemEffectiveness(SYS_Maneuver));
    else
        setAngularVelocity(rotationDiff * turn_speed * getSystemEffectiveness(SYS_Maneuver));
    
    if ((has_jump_drive && jump_delay > 0) || (has_warp_drive && warp_request > 0))
    {
        if (WarpJammer::isWarpJammed(getPosition()))
        {
            jump_delay = 0;
            warp_request = 0.0f;
        }
    }
    if (has_jump_drive && jump_delay > 0)
    {
        if (current_impulse > 0.0)
        {
            if (impulse_max_speed > 0)
                current_impulse -= delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse < 0.0)
                current_impulse = 0.0;
        }
        if (current_warp > 0.0)
        {
            current_warp -= delta;
            if (current_warp < 0.0)
                current_warp = 0.0;
        }
        jump_delay -= delta * getSystemEffectiveness(SYS_JumpDrive);
        if (jump_delay <= 0.0)
        {
            executeJump(jump_distance);
            jump_delay = 0.0;
        }
    }else if (has_warp_drive && (warp_request > 0 || current_warp > 0))
    {
        if (current_impulse > 0.0)
        {
            if (impulse_max_speed > 0)
                current_impulse -= delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse < 0.0)
                current_impulse = 0.0;
        }else{
            float destWarp = std::min(float(warp_request), max_warp);
            if (current_warp < destWarp) 
            {
                current_warp += delta / warp_charge_time;
                if (current_warp > destWarp)
                    current_warp = destWarp;  
            } else if (current_warp > destWarp)
            {
                current_warp -= std::max(1.0f, destWarp - current_warp) * delta / warp_decharge_time;
                if (current_warp < destWarp)
                    current_warp = destWarp;
            }
        }
    }else{
        if (has_jump_drive)
        {
            float f = getJumpDriveRechargeRate();
            if (f > 0)
            {
                if (jump_drive_charge < jump_drive_max_distance)
                {
                    float extra_charge = (delta / jump_drive_charge_time * jump_drive_max_distance) * f;
                    if (useEnergy(extra_charge * jump_drive_energy_per_km_charge / 1000.0))
                    {
                        jump_drive_charge += extra_charge;
                        if (jump_drive_charge >= jump_drive_max_distance)
                            jump_drive_charge = jump_drive_max_distance;
                    }
                }
            }else{
                jump_drive_charge += (delta / jump_drive_charge_time * jump_drive_max_distance) * f;
                if (jump_drive_charge < 0.0f)
                    jump_drive_charge = 0.0f;
            }
        }
        current_warp = 0.0;
        if (impulse_request > 1.0)
            impulse_request = 1.0;
        if (impulse_request < -1.0)
            impulse_request = -1.0;
        if (current_impulse < impulse_request)
        {
            if (impulse_max_speed > 0)
                current_impulse += delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse > impulse_request)
                current_impulse = impulse_request;
        }else if (current_impulse > impulse_request)
        {
            if (impulse_max_speed > 0)
                current_impulse -= delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse < impulse_request)
                current_impulse = impulse_request;
        }
    }

    // Add heat based on warp factor.
    addHeat(SYS_Warp, current_warp * delta * heat_per_warp);

    // Determine forward direction and velocity.
    sf::Vector2f forward = sf::vector2FromAngle(getRotation());
    setVelocity(forward * (current_impulse * impulse_max_speed * getSystemEffectiveness(SYS_Impulse) + current_warp * warp_speed_per_warp_level * getSystemEffectiveness(SYS_Warp)));

    if (combat_maneuver_boost_active > combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active -= delta;
        if (combat_maneuver_boost_active < combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_boost_active < combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active += delta;
        if (combat_maneuver_boost_active > combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active -= delta;
        if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }
    if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active += delta;
        if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }

    // If the ship is making a combat maneuver ...
    if (combat_maneuver_boost_active != 0.0 || combat_maneuver_strafe_active != 0.0)
    {
        // ... consume its combat maneuver boost.
        combat_maneuver_charge -= fabs(combat_maneuver_boost_active) * delta / combat_maneuver_boost_max_time;
        combat_maneuver_charge -= fabs(combat_maneuver_strafe_active) * delta / combat_maneuver_strafe_max_time;

        // Use boost only if we have boost available.
        if (combat_maneuver_charge <= 0.0)
        {
            combat_maneuver_charge = 0.0;
            combat_maneuver_boost_request = 0.0;
            combat_maneuver_strafe_request = 0.0;
        }else
        {
            setVelocity(getVelocity() + forward * combat_maneuver_boost_speed * combat_maneuver_boost_active);
            setVelocity(getVelocity() + sf::vector2FromAngle(getRotation() + 90) * combat_maneuver_strafe_speed * combat_maneuver_strafe_active);
        }
    // If the ship isn't making a combat maneuver, recharge its boost.
    }else if (combat_maneuver_charge < 1.0)
    {
        combat_maneuver_charge += (delta / combat_maneuver_charge_time) * (getSystemEffectiveness(SYS_Maneuver) + getSystemEffectiveness(SYS_Impulse)) / 2.0;
        if (combat_maneuver_charge > 1.0)
            combat_maneuver_charge = 1.0;
    }

    // Add heat to systems consuming combat maneuver boost.
    addHeat(SYS_Impulse, fabs(combat_maneuver_boost_active) * delta * heat_per_combat_maneuver_boost);
    addHeat(SYS_Maneuver, fabs(combat_maneuver_strafe_active) * delta * heat_per_combat_maneuver_strafe);

    for(int n = 0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].update(delta);
    }
    tractor_beam.update(delta);
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].update(delta);
    }
    
    for(int n = 0; n < max_docks_count; n++)
    {
        docks[n].update(delta);
    }

    for(int n=0; n<SYS_COUNT; n++)
    {
        systems[n].hacked_level = std::max(0.0f, systems[n].hacked_level - delta / unhack_time);
    }

    model_info.engine_scale = std::min(1.0f, (float) std::max(fabs(getAngularVelocity() / turn_speed), fabs(current_impulse)));
    if (has_jump_drive && jump_delay > 0.0f)
        model_info.warp_scale = (10.0f - jump_delay) / 10.0f;
    else
        model_info.warp_scale = 0.0;
}

float SpaceShip::getShieldRechargeRate(int shield_index)
{
    float rate = 0.3f;
    rate *= getSystemEffectiveness(getShieldSystemForShieldIndex(shield_index));
    if (docking_state == DS_Docked)
    {
        P<SpaceShip> docked_with_ship = docking_target;
        if (!docked_with_ship)
            rate *= 4.0;
    }
    return rate;
}

P<SpaceObject> SpaceShip::getTarget()
{
    if (game_server)
        return game_server->getObjectById(target_id);
    return game_client->getObjectById(target_id);
}

void SpaceShip::executeJump(float distance)
{
    float f = systems[SYS_JumpDrive].health;
    if (f <= 0.0)
        return;

    distance = (distance * f) + (distance * (1.0 - f) * random(0.5, 1.5));
    sf::Vector2f target_position = getPosition() + sf::vector2FromAngle(getRotation()) * distance;
    if (WarpJammer::isWarpJammed(target_position))
        target_position = WarpJammer::getFirstNoneJammedPosition(getPosition(), target_position);
    setPosition(target_position);
    addHeat(SYS_JumpDrive, jump_drive_heat_per_jump);
}

bool SpaceShip::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj) || !ship_template)
        return false;
    P<SpaceShip> ship = obj;
    if (!ship || !ship->ship_template)
        return false;
    return ship_template->can_be_docked_by_class.count(ship->ship_template->getClass()) > 0;
}

void SpaceShip::collide(Collisionable* other, float force)
{
    if (docking_state == DS_Docking)
    {
        P<SpaceObject> dock_object = P<Collisionable>(other);
        if (dock_object == docking_target)
        {
            docking_state = DS_Docked;
            docking_offset = sf::rotateVector(getPosition() - other->getPosition(), -other->getRotation());
            float length = sf::length(docking_offset);
            docking_offset = docking_offset / length * (length + 2.0f);
        }
    }
}

void SpaceShip::initializeJump(float distance)
{
    if (docking_state != DS_NotDocking)
        return;
    if (jump_drive_charge < jump_drive_max_distance) // You can only jump when the drive is fully charged
        return;
    if (jump_delay <= 0.0)
    {
        jump_distance = distance;
        jump_delay = 10.0;
        jump_drive_charge -= distance;
    }
}

void SpaceShip::requestDock(P<SpaceObject> target)
{
    if (!target || docking_state != DS_NotDocking || !target->canBeDockedBy(this))
        return;
    if (sf::length(getPosition() - target->getPosition()) > 1000 + target->getRadius())
        return;
    if (!canStartDocking())
        return;

    docking_state = DS_Docking;
    docking_target = target;
    warp_request = 0.0;
}

void SpaceShip::requestUndock()
{
    if (docking_state == DS_Docked)
    {
        docking_state = DS_NotDocking;
        if (getSystemEffectiveness(SYS_Impulse) > 0.1){
            impulse_request = 0.5;
        }
    }
}

void SpaceShip::abortDock()
{
    if (docking_state == DS_Docking)
    {
        docking_state = DS_NotDocking;
        impulse_request = 0.0;
        warp_request = 0.0;
        target_rotation = getRotation();
    }
}

int SpaceShip::scanningComplexity(P<SpaceObject> other)
{
    if (scanning_complexity_value > -1)
        return scanning_complexity_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 2;
        return 1;
    case SC_Advanced:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 3;
        return 2;
    }
    return 0;
}

int SpaceShip::scanningChannelDepth(P<SpaceObject> other)
{
    if (scanning_depth_value > -1)
        return scanning_depth_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        return 2;
    case SC_Advanced:
        return 2;
    }
    return 0;
}

void SpaceShip::scannedBy(P<SpaceObject> other)
{
    switch(getScannedStateFor(other))
    {
    case SS_NotScanned:
    case SS_FriendOrFoeIdentified:
        setScannedStateFor(other, SS_SimpleScan);
        break;
    case SS_SimpleScan:
        setScannedStateFor(other, SS_FullScan);
        break;
    case SS_FullScan:
        break;
    }
}

bool SpaceShip::isFriendOrFoeIdentified()
{
    LOG(WARNING) << "Depricated \"isFriendOrFoeIdentified\" function called, use isFriendOrFoeIdentifiedBy or isFriendOrFoeIdentifiedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) > SS_NotScanned)
            return true;
    }
    return false;
}

bool SpaceShip::isFullyScanned()
{
    LOG(WARNING) << "Depricated \"isFullyScanned\" function called, use isFullyScannedBy or isFullyScannedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) >= SS_FullScan)
            return true;
    }
    return false;
}

bool SpaceShip::isFriendOrFoeIdentifiedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FullScan;
}

bool SpaceShip::isFriendOrFoeIdentifiedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FullScan;
}

bool SpaceShip::canBeHackedBy(P<SpaceObject> other)
{
    return (!(this->isFriendly(other)) && this->isFriendOrFoeIdentifiedBy(other)) ;
}

std::vector<std::pair<string, float>> SpaceShip::getHackingTargets()
{
    std::vector<std::pair<string, float>> results;
    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        if (n != SYS_Reactor && hasSystem(ESystem(n)))
        {
            results.emplace_back(getSystemName(ESystem(n)), systems[n].hacked_level);
        }
    }
    return results;
}

void SpaceShip::hackFinished(P<SpaceObject> source, string target)
{
    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        if (hasSystem(ESystem(n)))
        {
            if (target == getSystemName(ESystem(n)))
            {
                systems[n].hacked_level = std::min(1.0f, systems[n].hacked_level + 0.5f);
                return;
            }
        }
    }
    LOG(WARNING) << "Unknown hacked target: " << target;
}

float SpaceShip::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    float frequency_damage_factor = 1.0;
    if (info.type == DT_Energy && gameGlobalInfo->use_beam_shield_frequencies)
    {
        frequency_damage_factor = frequencyVsFrequencyDamageFactor(info.frequency, shield_frequency);
    }
    ESystem system = getShieldSystemForShieldIndex(shield_index);

    //Shield damage reduction curve. Damage reduction gets slightly exponetial effective with power.
    // This also greatly reduces the ineffectiveness at low power situations.
    float shield_damage_exponent = 1.6;
    float shield_damage_divider = 7.0;
    float shield_damage_factor = 1.0 + powf(1.0, shield_damage_exponent) / shield_damage_divider-powf(getSystemEffectiveness(system), shield_damage_exponent) / shield_damage_divider;

    return shield_damage_factor * frequency_damage_factor;
}

void SpaceShip::didAnOffensiveAction()
{
    //We did an offensive action towards our target.
    // Check for each faction. If this faction knows if the target is an enemy or a friendly, it now knows if this object is an enemy or a friendly.
    for(unsigned int faction_id=0; faction_id<factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) == SS_NotScanned)
        {
            if (getTarget() && getTarget()->getScannedStateForFaction(faction_id) != SS_NotScanned)
                setScannedStateForFaction(faction_id, SS_FriendOrFoeIdentified);
        }
    }
}

void SpaceShip::takeHullDamage(float damage_amount, DamageInfo& info)
{
    if (gameGlobalInfo->use_system_damage)
    {
        if (info.system_target != SYS_None)
        {
            //Target specific system
            float system_damage = (damage_amount / hull_max) * 2.0;
            if (info.type == DT_Energy)
                system_damage *= 3.0;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[info.system_target].health -= system_damage;
            if (systems[info.system_target].health < -1.0)
                systems[info.system_target].health = -1.0;

            for(int n=0; n<2; n++)
            {
                ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (damage_amount / hull_max) * 1.0;
                systems[random_system].health -= system_damage;
                if (systems[random_system].health < -1.0)
                    systems[random_system].health = -1.0;
            }

            if (info.type == DT_Energy)
                damage_amount *= 0.02;
            else
                damage_amount *= 0.5;
        }else{
            ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
            //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
            float system_damage = (damage_amount / hull_max) * 3.0;
            if (info.type == DT_Energy)
                system_damage *= 2.5;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[random_system].health -= system_damage;
            if (systems[random_system].health < -1.0)
                systems[random_system].health = -1.0;
        }
    }

    ShipTemplateBasedObject::takeHullDamage(damage_amount, info);
}

void SpaceShip::destroyedByDamage(DamageInfo& info)
{
    ExplosionEffect* e = new ExplosionEffect();
    e->setSize(getRadius() * 1.5);
    e->setPosition(getPosition());
}

bool SpaceShip::hasSystem(ESystem system)
{
    switch(system)
    {
    case SYS_None:
    case SYS_COUNT:
        return false;
    case SYS_Warp:
        return has_warp_drive;
    case SYS_JumpDrive:
        return has_jump_drive;
    case SYS_MissileSystem:
        return weapon_tube_count > 0;
    case SYS_FrontShield:
        return shield_count > 0;
    case SYS_RearShield:
        return shield_count > 1;
    case SYS_Reactor:
        return ship_template->has_reactor;
    case SYS_BeamWeapons:
        return true;
    case SYS_Maneuver:
        return turn_speed > 0.0;
    case SYS_Impulse:
        return impulse_max_speed > 0.0;
    case SYS_Docks:
    case SYS_Drones:
        return docks[0].dock_type != Dock_Disabled;
    }
    return true;
}

float SpaceShip::getSystemEffectiveness(ESystem system)
{
    float power = systems[system].power_level;
    power *= (1.0f - systems[system].hacked_level * 0.75f);

    // Degrade all systems except the reactor once energy level drops below 10.
    if (system != SYS_Reactor)
    {
        if (energy_level < 10.0 && energy_level > 0.0 && power > 0.0)
            power = std::min(power * energy_level / 10.0f, power);
        else if (energy_level <= 0.0 || power <= 0.0)
            power = 0.0f;
    }

    // Degrade damaged systems.
    if (gameGlobalInfo && gameGlobalInfo->use_system_damage)
        return std::max(0.0f, power * systems[system].health);

    // If a system cannot be damaged, excessive heat degrades it.
    return std::max(0.0f, power * (1.0f - systems[system].heat_level));
}

void SpaceShip::setWeaponTubeCount(int amount)
{
    weapon_tube_count = std::max(0, std::min(amount, max_weapon_tubes));
    for(int n=weapon_tube_count; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].forceUnload();
    }
}

int SpaceShip::getWeaponTubeCount()
{
    return weapon_tube_count;
}

EMissileWeapons SpaceShip::getWeaponTubeLoadType(int index)
{
    if (index < 0 || index >= weapon_tube_count)
        return MW_None;
    if (!weapon_tube[index].isLoaded())
        return MW_None;
    return weapon_tube[index].getLoadType();
}

void SpaceShip::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].disallowLoadOf(type);
}

void SpaceShip::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    for(int n=0; n<MW_Count; n++)
        weapon_tube[index].disallowLoadOf(EMissileWeapons(n));
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::setWeaponTubeDirection(int index, float direction)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].setDirection(direction);
}

void SpaceShip::addBroadcast(int threshold, string message)
{
    if ((threshold < 0) || (threshold > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(ERROR) << "Invalid threshold: " << threshold;
        threshold = 0;
    }

    message = this->getCallSign() + " : " + message; //append the callsign at the start of broadcast

    sf::Color color = sf::Color(255, 204, 51); //default : yellow, should never be seen

    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        bool addtolog = 0;
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (this->isFriendly(ship))
            {
                color = sf::Color(154,255,154); //ally = light green
                addtolog = 1;
            }
            else if ((factionInfo[this->getFactionId()]->states[ship->getFactionId()] == FVF_Neutral) && ((threshold >= FVF_Neutral)))
            {
                color = sf::Color(128,128,128); //neutral = grey
                addtolog = 1;
            }
            else if ((this->isEnemy(ship)) && (threshold == FVF_Enemy))
            {
                color = sf::Color(255,102,102); //enemy = light red
                addtolog = 1;
            }

            if (addtolog)
            {
                ship->addToShipLog(message, color, "extern");
            }
        }
    }
}

std::unordered_map<string, string> SpaceShip::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret = ShipTemplateBasedObject::getGMInfo();
    return ret;
}

string SpaceShip::getScriptExportModificationsOnTemplate()
{
    // Exports attributes common to ships as Lua script function calls.
    // Initialize the exported string.
    string ret = "";

    // If traits don't differ from the ship template, don't bother exporting
    // them.
    if (getTypeName() != ship_template->getName())
        ret += ":setTypeName(" + getTypeName() + ")";
    if (hull_max != ship_template->hull)
        ret += ":setHullMax(" + string(hull_max, 0) + ")";
    if (hull_strength != ship_template->hull)
        ret += ":setHull(" + string(hull_strength, 0) + ")";
    if (impulse_max_speed != ship_template->impulse_speed)
        ret += ":setImpulseMaxSpeed(" + string(impulse_max_speed, 1) + ")";
    if (turn_speed != ship_template->turn_speed)
        ret += ":setRotationMaxSpeed(" + string(turn_speed, 1) + ")";
    if (has_jump_drive != ship_template->has_jump_drive)
        ret += ":setJumpDrive(" + string(has_jump_drive ? "true" : "false") + ")";
    if (has_warp_drive != (ship_template->warp_speed > 0))
        ret += ":setWarpDrive(" + string(has_warp_drive ? "true" : "false") + ")";

    // Shield data
    // Determine whether to export shield data.
    bool add_shields_max_line = getShieldCount() != ship_template->shield_count;
    bool add_shields_line = getShieldCount() != ship_template->shield_count;

    // If shield max and level don't differ from the template, don't bother
    // exporting them.
    for(int n = 0; n < getShieldCount(); n++)
    {
        if (getShieldMax(n) != ship_template->shield_level[n])
            add_shields_max_line = true;
        if (getShieldLevel(n) != ship_template->shield_level[n])
            add_shields_line = true;
    }

    // If we're exporting shield max ...
    if (add_shields_max_line)
    {
        ret += ":setShieldsMax(";

        // ... for each shield, export the shield max.
        for(int n = 0; n < getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";

            ret += string(getShieldMax(n));
        }

        ret += ")";
    }

    // If we're exporting shield level ...
    if (add_shields_line)
    {
        ret += ":setShields(";

        // ... for each shield, export the shield level.
        for(int n = 0; n < getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";

            ret += string(getShieldLevel(n));
        }

        ret += ")";
    }

    ///Missile weapon data
    if (weapon_tube_count != ship_template->weapon_tube_count)
        ret += ":setWeaponTubeCount(" + string(weapon_tube_count) + ")";

    for(int n=0; n<weapon_tube_count; n++)
    {
        WeaponTube& tube = weapon_tube[n];
        if (tube.getDirection() != ship_template->weapon_tube[n].direction)
            ret += ":setWeaponTubeDirection(" + string(n) + ", " + string(tube.getDirection(), 0) + ")";
        //TODO: Weapon tube "type_allowed_mask"
        //TODO: Weapon tube "load_time"
    }
    for(int n=0; n<MW_Count; n++)
    {
        if (weapon_storage_max[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorageMax(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage_max[n]) + ")";
        if (weapon_storage[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorage(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage[n]) + ")";
    }

    ///Beam weapon data
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (beam_weapons[n].getArc() != ship_template->beams[n].getArc()
         || beam_weapons[n].getDirection() != ship_template->beams[n].getDirection()
         || beam_weapons[n].getRange() != ship_template->beams[n].getRange()
         || beam_weapons[n].getTurretArc() != ship_template->beams[n].getTurretArc()
         || beam_weapons[n].getTurretDirection() != ship_template->beams[n].getTurretDirection()
         || beam_weapons[n].getTurretRotationRate() != ship_template->beams[n].getTurretRotationRate()
         || beam_weapons[n].getCycleTime() != ship_template->beams[n].getCycleTime()
         || beam_weapons[n].getDamage() != ship_template->beams[n].getDamage())
        {
            ret += ":setBeamWeapon(" + string(n) + ", " + string(beam_weapons[n].getArc(), 0) + ", " + string(beam_weapons[n].getDirection(), 0) + ", " + string(beam_weapons[n].getRange(), 0) + ", " + string(beam_weapons[n].getCycleTime(), 1) + ", " + string(beam_weapons[n].getDamage(), 1) + ")";
            ret += ":setBeamWeaponTurret(" + string(n) + ", " + string(beam_weapons[n].getTurretArc(), 0) + ", " + string(beam_weapons[n].getTurretDirection(), 0) + ", " + string(beam_weapons[n].getTurretRotationRate(), 0) + ")";
        }
    }

    if (tractor_beam.getMaxArea() != ship_template->tractor_beam.getMaxArea()
        || tractor_beam.getDragPerSecond() != ship_template->tractor_beam.getDragPerSecond()
        || tractor_beam.getMode() != TBM_Off 
        || tractor_beam.getArc() != 0.0f
        || tractor_beam.getDirection() != 0.0f
        || tractor_beam.getRange() != 0.0f)
    {
        ret += ":setTractorBeam(" + getTractorBeamModeName(tractor_beam.getMode()) + ", " + string(tractor_beam.getArc(), 0) + ", " + string(tractor_beam.getDirection(), 0) + ", " + string(tractor_beam.getRange(), 0) + ", " + string(tractor_beam.getMaxArea(), 0) + ", " + string(tractor_beam.getDragPerSecond(), 0) + ")";
    }
    return ret;
}

bool SpaceShip::tryDockDrone(SpaceShip* other){
    if(other->ship_template->getType() == ShipTemplate::TemplateType::Drone){
        Dock* dock = Dock::findOpenForDocking(docks, max_docks_count);
        if (dock){
            P<ShipCargo> cargo = new ShipCargo(other);
            dock->dock(cargo);
            return true;
        }
    }
    return false;
}

float SpaceShip::getDronesControlRange() { 
    return Tween<float>::easeInQuad(getSystemEffectiveness(SYS_Drones), 0.0, 3.0, 1, 37000); 
}

// Client-side functions to send a command to the server.
void SpaceShip::commandTargetRotation(float target)
{
    sf::Packet packet;
    packet << CMD_TARGET_ROTATION << target;
    sendClientCommand(packet);
}

void SpaceShip::commandRotation(float rotation)
{
    sf::Packet packet;
    packet << CMD_ROTATION << rotation;
    sendClientCommand(packet);
}

void SpaceShip::commandImpulse(float target)
{
    sf::Packet packet;
    packet << CMD_IMPULSE << target;
    sendClientCommand(packet);
}

void SpaceShip::commandWarp(int8_t target)
{
    sf::Packet packet;
    packet << CMD_WARP << target;
    sendClientCommand(packet);
}

void SpaceShip::commandJump(float distance)
{
    sf::Packet packet;
    packet << CMD_JUMP << distance;
    sendClientCommand(packet);
}

void SpaceShip::commandSetTarget(P<SpaceObject> target)
{
    sf::Packet packet;
    if (target)
        packet << CMD_SET_TARGET << target->getMultiplayerId();
    else
        packet << CMD_SET_TARGET << int32_t(-1);
    sendClientCommand(packet);
}

void SpaceShip::commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType)
{
    sf::Packet packet;
    packet << CMD_LOAD_TUBE << tubeNumber << missileType;
    sendClientCommand(packet);
}

void SpaceShip::commandUnloadTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_UNLOAD_TUBE << tubeNumber;
    sendClientCommand(packet);
}

void SpaceShip::commandFireTube(int8_t tubeNumber, float missile_target_angle)
{
    sf::Packet packet;
    packet << CMD_FIRE_TUBE << tubeNumber << missile_target_angle;
    sendClientCommand(packet);
}

void SpaceShip::commandFireTubeAtTarget(int8_t tubeNumber, P<SpaceObject> target)
{
  float targetAngle = 0.0;
  
  if (!target || tubeNumber < 0 || tubeNumber >= getWeaponTubeCount())
    return;
  
  targetAngle = weapon_tube[tubeNumber].calculateFiringSolution(target);
  
  if (targetAngle == std::numeric_limits<float>::infinity())
      targetAngle = getRotation() + weapon_tube[tubeNumber].getDirection();
    
  commandFireTube(tubeNumber, targetAngle);
}

void SpaceShip::commandDock(P<SpaceObject> object)
{
    if (!object) return;
    sf::Packet packet;
    packet << CMD_DOCK << object->getMultiplayerId();
    sendClientCommand(packet);
}

void SpaceShip::commandUndock()
{
    sf::Packet packet;
    packet << CMD_UNDOCK;
    sendClientCommand(packet);
}

void SpaceShip::commandAbortDock()
{
    sf::Packet packet;
    packet << CMD_ABORT_DOCK;
    sendClientCommand(packet);
}

void SpaceShip::commandSetBeamFrequency(int32_t frequency)
{
    sf::Packet packet;
    packet << CMD_SET_BEAM_FREQUENCY << frequency;
    sendClientCommand(packet);
}

void SpaceShip::commandSetBeamSystemTarget(ESystem system)
{
    sf::Packet packet;
    packet << CMD_SET_BEAM_SYSTEM_TARGET << system;
    sendClientCommand(packet);
}

void SpaceShip::commandSetShieldFrequency(int32_t frequency)
{
    sf::Packet packet;
    packet << CMD_SET_SHIELD_FREQUENCY << frequency;
    sendClientCommand(packet);
}

void SpaceShip::commandCombatManeuverBoost(float amount)
{
    combat_maneuver_boost_request = amount;
    sf::Packet packet;
    packet << CMD_COMBAT_MANEUVER_BOOST << amount;
    sendClientCommand(packet);
}

void SpaceShip::commandCombatManeuverStrafe(float amount)
{
    combat_maneuver_strafe_request = amount;
    sf::Packet packet;
    packet << CMD_COMBAT_MANEUVER_STRAFE << amount;
    sendClientCommand(packet);
}

void SpaceShip::commandLaunchProbe(sf::Vector2f target_position)
{
    sf::Packet packet;
    packet << CMD_LAUNCH_PROBE << target_position;
    sendClientCommand(packet);
}

void SpaceShip::commandLaunchCargo(int index)
{
    sf::Packet packet;
    packet << CMD_LAUNCH_CARGO << index;
    sendClientCommand(packet);
}

void SpaceShip::commandMoveCargo(int index)
{
    sf::Packet packet;
    packet << CMD_MOVE_CARGO << index;
    sendClientCommand(packet);
}

void SpaceShip::commandCancelMoveCargo(int index)
{
    sf::Packet packet;
    packet << CMD_CANCEL_MOVE_CARGO << index;
    sendClientCommand(packet);
}

void SpaceShip::commandSetDockMoveTarget(int srcIdx, int destIdx)
{
    sf::Packet packet;
    packet << CMD_SET_DOCK_MOVE_TARGET << srcIdx << destIdx;
    sendClientCommand(packet);
}

void SpaceShip::commandSetDockEnergyRequest(int index, float value)
{
    sf::Packet packet;
    packet << CMD_SET_DOCK_ENERGY_REQUEST << index << value;
    sendClientCommand(packet);
}

void SpaceShip::commandHackingFinished(P<SpaceObject> target, string target_system)
{
    sf::Packet packet;
    packet << CMD_HACKING_FINISHED;
    packet << target->getMultiplayerId();
    packet << target_system;
    sendClientCommand(packet);
}

void SpaceShip::commandSetTractorBeamDirection(float direction){
    sf::Packet packet;
    packet << CMD_SET_TRACTOR_BEAM_DIRECTION << direction;
    sendClientCommand(packet);
}

void SpaceShip::commandSetTractorBeamArc(float arc){
    sf::Packet packet;
    packet << CMD_SET_TRACTOR_BEAM_ARC << arc;
    sendClientCommand(packet);
}
void SpaceShip::commandSetTractorBeamRange(float range){
    sf::Packet packet;
    packet << CMD_SET_TRACTOR_BEAM_RANGE << range;
    sendClientCommand(packet);
}
void SpaceShip::commandSetTractorBeamMode(ETractorBeamMode mode){
    sf::Packet packet;
    packet << CMD_SET_TRACTOR_BEAM_MODE << int(mode);
    sendClientCommand(packet);
}

string getMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return "Homing";
    case MW_Nuke:
        return "Nuke";
    case MW_Mine:
        return "Mine";
    case MW_EMP:
        return "EMP";
    case MW_HVLI:
        return "HVLI";
    default:
        return "UNK: " + string(int(missile));
    }
}

float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency)
{
    if (beam_frequency < 0 || shield_frequency < 0)
        return 1.0;

    float diff = abs(beam_frequency - shield_frequency);
    float f1 = sinf(Tween<float>::linear(diff, 0, SpaceShip::max_frequency, 0, M_PI * (1.2 + shield_frequency * 0.05)) + M_PI / 2);
    f1 = f1 * Tween<float>::easeInCubic(diff, 0, SpaceShip::max_frequency, 1.0, 0.1);
    f1 = Tween<float>::linear(f1, 1.0, -1.0, 0.5, 1.5);
    return f1;
}

string frequencyToString(int frequency)
{
    return string(400 + (frequency * 20)) + "THz";
}

#ifndef _MSC_VER
#include "spaceship.hpp"
#endif
