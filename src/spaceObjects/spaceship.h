#ifndef SPACESHIP_H
#define SPACESHIP_H

#include "shipTemplateBasedObject.h"
#include "spaceStation.h"
#include "spaceshipParts/beamWeapon.h"
#include "spaceshipParts/tractorBeam.h"
#include "spaceshipParts/weaponTube.h"
#include "spaceshipParts/dock.h"

enum EMainScreenSetting
{
    MSS_Front = 0,
    MSS_Back,
    MSS_Left,
    MSS_Right,
    MSS_Target,
    MSS_Tactical,
    MSS_LongRange,
    MSS_GlobalRange,
    MSS_ShipState
};
template<> void convert<EMainScreenSetting>::param(lua_State* L, int& idx, EMainScreenSetting& mss);

enum EMainScreenOverlay
{
    MSO_HideComms = 0,
    MSO_ShowComms
};
template<> void convert<EMainScreenOverlay>::param(lua_State* L, int& idx, EMainScreenOverlay& mso);

enum EDockingState
{
    DS_NotDocking = 0,
    DS_Docking,
    DS_Docked
};

class ShipSystem
{
public:
    float health; //1.0-0.0, where 0.0 is fully broken.
    float power_level; //0.0-3.0, default 1.0
    float power_request;
    float heat_level; //0.0-1.0, system will damage at 1.0
    float coolant_level; //0.0-10.0
    float coolant_request;
    float hacked_level; //0.0-1.0

    float getHeatingDelta()
    {
        return powf(1.7, power_level - 1.0) - (1.01 + coolant_level * 0.1);
    }
};

class SpaceShip : public ShipTemplateBasedObject
{
protected:
    static const int16_t CMD_TARGET_ROTATION = 0x0001;
    static const int16_t CMD_IMPULSE = 0x0002;
    static const int16_t CMD_WARP = 0x0003;
    static const int16_t CMD_JUMP = 0x0004;
    static const int16_t CMD_SET_TARGET = 0x0005;
    static const int16_t CMD_LOAD_TUBE = 0x0006;
    static const int16_t CMD_UNLOAD_TUBE = 0x0007;
    static const int16_t CMD_FIRE_TUBE = 0x0008;
    static const int16_t CMD_DOCK = 0x0010;
    static const int16_t CMD_UNDOCK = 0x0011;
    static const int16_t CMD_SET_BEAM_FREQUENCY = 0x0018;
    static const int16_t CMD_SET_BEAM_SYSTEM_TARGET = 0x0019;
    static const int16_t CMD_SET_SHIELD_FREQUENCY = 0x001A; // need player override
    static const int16_t CMD_COMBAT_MANEUVER_BOOST = 0x0021;
    static const int16_t CMD_COMBAT_MANEUVER_STRAFE = 0x0022;
    static const int16_t CMD_LAUNCH_PROBE = 0x0023; // need player override
    static const int16_t CMD_ABORT_DOCK = 0x0027;
    static const int16_t CMD_HACKING_FINISHED = 0x0029;
    static const int16_t CMD_LAUNCH_CARGO = 0x002B;
    static const int16_t CMD_MOVE_CARGO = 0x002C;
    static const int16_t CMD_CANCEL_MOVE_CARGO = 0x002D;
    static const int16_t CMD_SET_DOCK_MOVE_TARGET = 0x002E;
    static const int16_t CMD_SET_DOCK_ENERGY_REQUEST = 0x002F;
    static const int16_t CMD_SET_TRACTOR_BEAM_DIRECTION = 0x0031;
    static const int16_t CMD_SET_TRACTOR_BEAM_ARC = 0x0032;
    static const int16_t CMD_SET_TRACTOR_BEAM_RANGE = 0x0033;
    static const int16_t CMD_SET_TRACTOR_BEAM_MODE = 0x0034;
    static const int16_t CMD_ROTATION = 0x0035;
public:
    constexpr static int max_frequency = 20;
    constexpr static float combat_maneuver_charge_time = 20.0f; /*< Amount of time it takes to fully charge the combat maneuver system */
    constexpr static float combat_maneuver_boost_max_time = 3.0f; /*< Amount of time we can boost with a fully charged combat maneuver system */
    constexpr static float combat_maneuver_strafe_max_time = 3.0f; /*< Amount of time we can strafe with a fully charged combat maneuver system */
    constexpr static float warp_charge_time = 4.0f;
    constexpr static float warp_decharge_time = 2.0f;
    constexpr static float jump_drive_charge_time = 90.0;   /*<Total charge time for the jump drive after a max range jump */
    constexpr static float dock_move_time = 15.0f; // It takes this amount of time to move cargo between two docks
    constexpr static float jump_drive_energy_per_km_charge = 4.0f;
    constexpr static float jump_drive_heat_per_jump = 0.35;
    constexpr static float heat_per_combat_maneuver_boost = 0.2;
    constexpr static float heat_per_combat_maneuver_strafe = 0.2;
    constexpr static float heat_per_warp = 0.02;
    constexpr static float unhack_time = 180.0f; //It takes this amount of time to go from 100% hacked to 0% hacked for systems.

    // Content of a line in the ship's log
    class ShipLogEntry
    {
    public:
        string prefix;
        string text;
        sf::Color color;
        string station;

        ShipLogEntry() {}
        ShipLogEntry(string prefix, string text, sf::Color color, string station)
        : prefix(prefix), text(text), color(color), station(station) {}

        bool operator!=(const ShipLogEntry& e) { return prefix != e.prefix || text != e.text || color != e.color || station != e.station; }
    };

    float energy_level;
    float max_energy_level;
    Dock docks[max_docks_count];

    ShipSystem systems[SYS_COUNT];
    /*!
     *[input] Ship will try to aim to this rotation. (degrees)
     */
    float target_rotation;

    /*!
     *[input] Ship will rotate in this velocity. ([-1,1], overrides target_rotation)
     */
    float rotation;

    /*!
     * [input] Amount of impulse requested from the user (-1.0 to 1.0)
     */
    float impulse_request;

    /*!
     * [output] Amount of actual impulse from the engines (-1.0 to 1.0)
     */
    float current_impulse;

    /*!
     * [config] Speed of rotation, in deg/second
     */
    float turn_speed;

    /*!
     * [config] Max speed of the impulse engines, in m/s
     */
    float impulse_max_speed;

    /*!
     * [config] Impulse engine acceleration, in (m/s)/s
     */
    float impulse_acceleration;

    /*!
     * [config] True if we have a warpdrive.
     */
    bool has_warp_drive;

    /*!
     * [output] Current maximum warp amount, from 0.0 to 4.0
     */
    float max_warp;

    /*!
     * [input] Level of warp requested, from 0 to 4
     */
    int8_t warp_request;

    /*!
     * [output] Current active warp amount, from 0.0 to 4.0
     */
    float current_warp;

    /*!
     * [config] Amount of speed per warp level, in m/s
     */
    float warp_speed_per_warp_level;

    /*!
     * [output] How much charge there is in the combat maneuvering system (0.0-1.0)
     */
    float combat_maneuver_charge;
    /*!
     * [input] How much boost we want at this moment (0.0-1.0)
     */
    float combat_maneuver_boost_request;
    float combat_maneuver_boost_active;

    float combat_maneuver_strafe_request;
    float combat_maneuver_strafe_active;

    float combat_maneuver_boost_speed; /*< [config] Speed to indicate how fast we will fly forwards with a full boost */
    float combat_maneuver_strafe_speed; /*< [config] Speed to indicate how fast we will fly sideways with a full strafe */

    bool has_jump_drive;      //[config]
    float jump_drive_charge; //[output]
    float jump_distance;     //[output]
    float jump_delay;        //[output]
    float jump_drive_min_distance; //[config]
    float jump_drive_max_distance; //[config]
    float wormhole_alpha;    //Used for displaying the Warp-postprocessor

    int weapon_storage[MW_Count];
    int weapon_storage_max[MW_Count];
    int8_t weapon_tube_count;
    WeaponTube weapon_tube[max_weapon_tubes];

    /*!
     * [output] Frequency of beam weapons
     */
    int beam_frequency;
    ESystem beam_system_target;
    BeamWeapon beam_weapons[max_beam_weapons];
    TractorBeam tractor_beam;
    /**
     * Frequency setting of the shields.
     */
    int shield_frequency;

    /// MultiplayerObjectID of the targeted object, or -1 when no target is selected.
    int32_t target_id;

    EDockingState docking_state;
    P<SpaceObject> docking_target; //Server only
    sf::Vector2f docking_offset; //Server only

    uint8 extern_log_size;
    uint8 intern_log_size;
    std::vector<ShipLogEntry> ships_log_extern;
    std::vector<ShipLogEntry> ships_log_intern;
    

    SpaceShip(string multiplayerClassName, float multiplayer_significant_range=-1);

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent() override;
#endif
    /*!
     * Draw this ship on the radar.
     */
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;
    void drawBeamOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, 
        sf::Color color, sf::Vector2f beam_position, float beam_direction, float beam_arc, float beam_range);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;
    void onReceiveClientCommand(int32_t client_id, sf::Packet& packet);
    virtual void handleClientCommand(int32_t client_id, int16_t command, sf::Packet& packet);

    virtual void update(float delta) override;
    virtual float getShieldRechargeRate(int shield_index) override;
    virtual float getShieldDamageFactor(DamageInfo& info, int shield_index) override;
    float getJumpDriveRechargeRate() { return Tween<float>::linear(getSystemEffectiveness(SYS_JumpDrive), 0.0, 1.0, -0.25, 1.0); }

    /*!
     * Check if the ship can be targeted.
     */
    virtual bool canBeTargetedBy(P<SpaceObject> other) override { return true; }

    /*!
     * didAnOffensiveAction is called whenever this ship does something offesive towards an other object
     * this can identify the ship as friend or foe.
     */
    void didAnOffensiveAction();

    /*!
     * Spaceship takes damage directly on hull.
     * This is used when shields are down or by weapons that ignore shields.
     * \param damage_amount Damage to be delt.
     * \param info Information about damage type (usefull for damage reduction, etc)
     */
    virtual void takeHullDamage(float damage_amount, DamageInfo& info) override;

    /*!
     * Spaceship is destroyed by damage.
     * \param info Information about damage type
     */
    virtual void destroyedByDamage(DamageInfo& info);

    /*!
     * Jump in current direction
     * \param distance Distance to jump in meters)
     */
    virtual void executeJump(float distance);

    /*!
     * Check if object can dock with this ship.
     * \param object Object that wants to dock.
     */
    virtual bool canBeDockedBy(P<SpaceObject> obj);

    virtual void collide(Collisionable* other, float force) override;

    /*!
     * Start the jumping procedure.
     */
    void initializeJump(float distance);

    /*!
     * Request to dock with target.
     */
    void requestDock(P<SpaceObject> target);

    /*!
     * Request undock with current docked object
     */
    void requestUndock();

    /*!
     * Abort the current dock request
     */
    void abortDock();

    /// Dummy virtual function to use energy. Only player ships currently model energy use.
    virtual bool useEnergy(float amount) { return true; }

    /// Dummy virtual function to add heat on a system. The player ship class has an actual implementation of this as only player ships model heat right now.
    virtual void addHeat(ESystem system, float amount) {}

    virtual bool canBeScannedBy(P<SpaceObject> other) override { return getScannedStateFor(other) != SS_FullScan; }
    virtual int scanningComplexity(P<SpaceObject> other) override;
    virtual int scanningChannelDepth(P<SpaceObject> other) override;
    virtual void scannedBy(P<SpaceObject> other) override;

    // Ship's log functions
    void addToShipLog(string message, sf::Color color, string station = "extern");
    void addToShipLogBy(string message, P<SpaceObject> target);
    const std::vector<ShipLogEntry>& getShipsLog(string station) const;

    bool isFriendOrFoeIdentified();//[DEPRICATED]
    bool isFullyScanned();//[DEPRICATED]
    bool isFriendOrFoeIdentifiedBy(P<SpaceObject> other);
    bool isFullyScannedBy(P<SpaceObject> other);
    bool isFriendOrFoeIdentifiedByFaction(int faction_id);
    bool isFullyScannedByFaction(int faction_id);

    virtual bool canBeHackedBy(P<SpaceObject> other) override;
    virtual std::vector<std::pair<string, float> > getHackingTargets() override;
    virtual void hackFinished(P<SpaceObject> source, string target) override;

    /*!
     * Check if ship has certain system
     */
    bool hasSystem(ESystem system);

    /*!
     * Check effectiveness of system.
     * If system has more / less power or is damages, this can influence the effectiveness.
     * \return float 0. to 1.
     */
    float getSystemEffectiveness(ESystem system);

    virtual void applyTemplateValues();

    P<SpaceObject> getTarget();

    virtual std::unordered_map<string, string> getGMInfo();

    bool isDocked(P<SpaceObject> target) { return docking_state == DS_Docked && docking_target == target; }
    bool canStartDocking() { return current_warp <= 0.0 && (!has_jump_drive || jump_delay <= 0.0); }
    int getWeaponStorage(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage[weapon]; }
    int getWeaponStorageMax(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage_max[weapon]; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage[weapon] = amount; }
    void setWeaponStorageMax(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage_max[weapon] = amount; weapon_storage[weapon] = std::min(int(weapon_storage[weapon]), amount); }
    float getMaxEnergy() { return max_energy_level; }
    void setMaxEnergy(float amount) { if (amount > 0.0) { max_energy_level = amount;} }
    float getEnergy() { return energy_level; }
    void setEnergy(float amount) { if ( (amount > 0.0) && (amount <= max_energy_level)) { energy_level = amount; } }
    float getSystemHealth(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].health; }
    void setSystemHealth(ESystem system, float health) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].health = std::min(1.0f, std::max(-1.0f, health)); }
    float getSystemHeat(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].heat_level; }
    void setSystemHeat(ESystem system, float heat) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].heat_level = std::min(1.0f, std::max(0.0f, heat)); }
    float getSystemPower(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].power_level; }
    void setSystemPower(ESystem system, float power) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].power_level = std::min(3.0f, std::max(0.0f, power)); }
    float getSystemCoolant(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].coolant_level; }
    void setSystemCoolant(ESystem system, float coolant) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].coolant_level = std::min(1.0f, std::max(0.0f, coolant)); }
    float getImpulseMaxSpeed() { return impulse_max_speed; }
    void setImpulseMaxSpeed(float speed) { impulse_max_speed = speed; }
    float getRotationMaxSpeed() { return turn_speed; }
    void setRotationMaxSpeed(float speed) { turn_speed = speed; }
    void setCombatManeuver(float boost, float strafe) { combat_maneuver_boost_speed = boost; combat_maneuver_strafe_speed = strafe; }

    bool hasJumpDrive() { return has_jump_drive; }
    void setJumpDrive(bool has_jump) { has_jump_drive = has_jump; }
    void setJumpDriveRange(float min, float max) { jump_drive_min_distance = min; jump_drive_max_distance = max; }
    bool hasWarpDrive() { return has_warp_drive; }
    void setWarpDrive(bool has_warp)
    {
        has_warp_drive = has_warp;
        if (has_warp_drive)
        {
            if (warp_speed_per_warp_level < 100)
                warp_speed_per_warp_level = 1000;
        }else{
            warp_request = 0.0;
            warp_speed_per_warp_level = 0;
        }
    }

    float getBeamWeaponArc(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getArc(); }
    float getBeamWeaponDirection(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getDirection(); }
    float getBeamWeaponRange(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getRange(); }

    float getBeamWeaponTurretArc(int index) 
    {
        if (index < 0 || index >= max_beam_weapons)
            return 0.0;
        return beam_weapons[index].getTurretArc();
    }

    float getBeamWeaponTurretDirection(int index)
    {
        if (index < 0 || index >= max_beam_weapons)
            return 0.0;
        return beam_weapons[index].getTurretDirection();
    }

    float getBeamWeaponTurretRotationRate(int index)
    {
        if (index < 0 || index >= max_beam_weapons)
            return 0.0;
        return beam_weapons[index].getTurretRotationRate();
    }

    float getBeamWeaponCycleTime(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getCycleTime(); }
    float getBeamWeaponDamage(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getDamage(); }
    float getBeamWeaponEnergyPerFire(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getEnergyPerFire(); }
    float getBeamWeaponHeatPerFire(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].getHeatPerFire(); }

    int getShieldsFrequency(void){ return shield_frequency; }
    void setShieldsFrequency(float freq) { if ((freq > SpaceShip::max_frequency) || (freq < 0)) return; shield_frequency = freq;}
    
    int getBeamsFrequency(void){ return beam_frequency; }

    void setBeamWeapon(int index, float arc, float direction, float range, float cycle_time, float damage)
    {
        if (index < 0 || index >= max_beam_weapons)
            return;
        beam_weapons[index].setArc(arc);
        beam_weapons[index].setDirection(direction);
        beam_weapons[index].setRange(range);
        beam_weapons[index].setCycleTime(cycle_time);
        beam_weapons[index].setDamage(damage);
    }

    void setBeamWeaponTurret(int index, float arc, float direction, float rotation_rate)
    {
        if (index < 0 || index >= max_beam_weapons)
            return;
        beam_weapons[index].setTurretArc(arc);
        beam_weapons[index].setTurretDirection(direction);
        beam_weapons[index].setTurretRotationRate(rotation_rate);
    }

    void setBeamWeaponTexture(int index, string texture)
    {
        if (index < 0 || index >= max_beam_weapons)
            return;
        beam_weapons[index].setBeamTexture(texture);
    }

    void setBeamWeaponEnergyPerFire(int index, float energy) { if (index < 0 || index >= max_beam_weapons) return; return beam_weapons[index].setEnergyPerFire(energy); }
    void setBeamWeaponHeatPerFire(int index, float heat) { if (index < 0 || index >= max_beam_weapons) return; return beam_weapons[index].setHeatPerFire(heat); }
    void setTractorBeam(ETractorBeamMode mode, float arc, float direction, float range, float max_area, float drag_per_second)
    {
        tractor_beam.setMode(mode);
        tractor_beam.setArc(arc);
        tractor_beam.setDirection(direction);
        tractor_beam.setRange(range);
        tractor_beam.setMaxArea(max_area);
        tractor_beam.setDragPerSecond(drag_per_second);
    }
    void setWeaponTubeCount(int amount);
    int getWeaponTubeCount();
    EMissileWeapons getWeaponTubeLoadType(int index);
    void weaponTubeAllowMissle(int index, EMissileWeapons type);
    void weaponTubeDisallowMissle(int index, EMissileWeapons type);
    void setWeaponTubeExclusiveFor(int index, EMissileWeapons type);
    void setWeaponTubeDirection(int index, float direction);

    void setRadarTrace(string trace) { radar_trace = trace; }

    void addBroadcast(int threshold, string message);

    //Return a string that can be appended to an object create function in the lua scripting.
    // This function is used in getScriptExport calls to adjust for tweaks done in the GM screen.
    string getScriptExportModificationsOnTemplate();
    bool tryDockDrone(SpaceShip* other);
    float getDronesControlRange();
        // Client command functions
    void commandTargetRotation(float target);
    void commandRotation(float rotation);
    void commandImpulse(float target);
    void commandWarp(int8_t target);
    void commandJump(float distance);
    void commandSetTarget(P<SpaceObject> target);
    void commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType);
    void commandUnloadTube(int8_t tubeNumber);
    void commandFireTube(int8_t tubeNumber, float missile_target_angle);    
    void commandFireTubeAtTarget(int8_t tubeNumber, P<SpaceObject> target);
    void commandDock(P<SpaceObject> station);
    void commandUndock();
    void commandAbortDock();
    void commandSetBeamFrequency(int32_t frequency);
    void commandSetBeamSystemTarget(ESystem system);
    void commandSetShieldFrequency(int32_t frequency);
    void commandCombatManeuverBoost(float amount);
    void commandCombatManeuverStrafe(float strafe);
    void commandLaunchProbe(sf::Vector2f target_position);
    void commandLaunchCargo(int index);
    void commandMoveCargo(int index);
    void commandCancelMoveCargo(int index);
    void commandSetDockMoveTarget(int srcIdx, int destIdx);
    void commandSetDockEnergyRequest(int index, float value);
    void commandHackingFinished(P<SpaceObject> target, string target_system);
    void commandSetTractorBeamDirection(float direction);
    void commandSetTractorBeamArc(float arc);
    void commandSetTractorBeamRange(float range);
    void commandSetTractorBeamMode(ETractorBeamMode range);

};

float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency);

string getMissileWeaponName(EMissileWeapons missile);
REGISTER_MULTIPLAYER_ENUM(EMissileWeapons);
REGISTER_MULTIPLAYER_ENUM(EWeaponTubeState);
REGISTER_MULTIPLAYER_ENUM(EMainScreenSetting);
REGISTER_MULTIPLAYER_ENUM(EMainScreenOverlay);
REGISTER_MULTIPLAYER_ENUM(EDockingState);
REGISTER_MULTIPLAYER_ENUM(EScannedState);
REGISTER_MULTIPLAYER_ENUM(EDockType);
REGISTER_MULTIPLAYER_ENUM(EDockState);
REGISTER_MULTIPLAYER_ENUM(ETractorBeamMode);


string frequencyToString(int frequency);

#ifdef _MSC_VER
// MFC: GCC does proper external template instantiation, VC++ doesn't.
#include "spaceship.hpp"
#endif

#endif//SPACESHIP_H
