#ifndef SPACE_SHIP_H
#define SPACE_SHIP_H

#include "shipTemplateBasedObject.h"
#include "spaceStation.h"
#include "beamWeapon.h"

enum EWeaponTubeState
{
    WTS_Empty,
    WTS_Loading,
    WTS_Loaded,
    WTS_Unloading
};
enum EMainScreenSetting
{
    MSS_Front = 0,
    MSS_Back,
    MSS_Left,
    MSS_Right,
    MSS_Tactical,
    MSS_LongRange
};
template<> void convert<EMainScreenSetting>::param(lua_State* L, int& idx, EMainScreenSetting& mss);

enum EDockingState
{
    DS_NotDocking = 0,
    DS_Docking,
    DS_Docked
};
enum EScannedState
{
    SS_NotScanned,
    SS_FriendOrFoeIdentified,
    SS_SimpleScan,
    SS_FullScan
};

class ShipSystem
{
public:
    float health; //1.0-0.0, where 0.0 is fully broken.
    float power_level; //0.0-3.0, default 1.0
    float heat_level; //0.0-1.0, system will damage at 1.0
    float coolant_level; //0.0-10.0

    float getHeatingDelta()
    {
        return powf(1.7, power_level - 1.0) - (1.01 + coolant_level * 0.1);
    }
};

class WeaponTube : public sf::NonCopyable
{
public:
    EMissileWeapons type_loaded;
    EWeaponTubeState state;
    float delay;
};

class SpaceShip : public ShipTemplateBasedObject
{
public:
    constexpr static int max_frequency = 20;
    constexpr static float combat_maneuver_charge_time = 20.0f;
    constexpr static float warp_charge_time = 4.0f;
    constexpr static float warp_decharge_time = 2.0f;
    constexpr static float jump_drive_charge_time_per_km = 2.0;
    constexpr static float jump_drive_min_distance = 5.0;
    constexpr static float jump_drive_max_distance = 50.0;

    int engineering_crew_max;
    int engineering_crew;
    int engineering_crew_injuried;

    float energy_level;
    ShipSystem systems[SYS_COUNT];
    /*!
     *[input] Ship will try to aim to this rotation. (degrees)
     */
    float target_rotation;

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

    bool has_jump_drive;      //[config]
    float jump_drive_charge; //[output]
    float jump_distance;     //[output]
    float jump_delay;        //[output]
    float wormhole_alpha;    //Used for displaying the Warp-postprocessor

    int8_t weapon_storage[MW_Count];
    int8_t weapon_storage_max[MW_Count];
    int8_t weapon_tubes;
    float tube_load_time;
    float tube_recharge_factor;
    WeaponTube weaponTube[max_weapon_tubes];

    /*!
     * [output] Frequency of beam weapons
     */
    int beam_frequency;
    ESystem beam_system_target;
    BeamWeapon beam_weapons[max_beam_weapons];

    /**
     * Frequency setting of the shields.
     */
    int shield_frequency;

    /// MultiplayerObjectID of the targeted object, or -1 when no target is selected.
    int32_t target_id;

    /*!
     * TODO; Needs to be fixed for multiplayer!
     */
    EScannedState scanned_by_player;

    EDockingState docking_state;
    P<SpaceObject> docking_target; //Server only
    sf::Vector2f docking_offset; //Server only

    SpaceShip(string multiplayerClassName, float multiplayer_significant_range=-1);

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent() override;
#endif
    /*!
     * Draw this ship on the radar.
     */
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual void update(float delta);
    virtual float getShieldRechargeRate(int shield_index) override;
    virtual float getShieldDamageFactor(DamageInfo& info, int shield_index) override;

    /*!
     * Check if the ship can be targeted.
     */
    virtual bool canBeTargeted() { return true; }

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
     * Fire beamweapon
     * \param index Index of beam weapon to be fired
     * \param target of the beam weapon.
     */
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);

    /*!
     * Check if object can dock with this ship.
     * \param object Object that wants to dock.
     */
    virtual bool canBeDockedBy(P<SpaceObject> obj);

    virtual void collide(Collisionable* other, float force) override;

    /*!
     * Load a missile tube.
     * \param tube_number Index of the tube to be loaded.
     * \param type Weapon type that is loaded.
     */
    void loadTube(int tube_number, EMissileWeapons type);

    /*!
     * Fire a missile tube.
     * \param tube_number Index of the tube to be fired.
     * \param target_angle Angle in degrees to where the missile needs to be shot.
     */
    void fireTube(int tube_number, float target_angle);

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

    virtual bool canBeScanned() { return scanned_by_player != SS_FullScan; }
    virtual int scanningComplexity();
    virtual int scanningChannelDepth();
    virtual void scanned() { if (scanned_by_player == SS_SimpleScan) scanned_by_player = SS_FullScan; else scanned_by_player = SS_SimpleScan; }
    void setScanned(bool scanned) { scanned_by_player = scanned ? SS_FullScan : SS_NotScanned; }
    bool isFriendOrFoeIdentified() { return scanned_by_player >= SS_FriendOrFoeIdentified; }
    bool isScanned() { return scanned_by_player >= SS_SimpleScan; }
    bool isFullyScanned() { return scanned_by_player >= SS_FullScan; }

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
    int getWeaponStorage(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage[weapon]; }
    int getWeaponStorageMax(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage_max[weapon]; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage[weapon] = amount; }
    void setWeaponStorageMax(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage_max[weapon] = amount; weapon_storage[weapon] = std::min(int(weapon_storage[weapon]), amount); }
    float getSystemHealth(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].health; }
    void setSystemHealth(ESystem system, float health) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].health = std::min(1.0f, std::max(-1.0f, health)); }
    float getSystemHeat(ESystem system) { if (system >= SYS_COUNT) return 0.0; if (system <= SYS_None) return 0.0; return systems[system].heat_level; }
    void setSystemHeat(ESystem system, float heat) { if (system >= SYS_COUNT) return; if (system <= SYS_None) return; systems[system].heat_level = std::min(1.0f, std::max(0.0f, heat)); }

    bool hasJumpDrive() { return has_jump_drive; }
    void setJumpDrive(bool has_jump) { has_jump_drive = has_jump; }
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

    float getBeamWeaponArc(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].arc; }
    float getBeamWeaponDirection(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].direction; }
    float getBeamWeaponRange(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].range; }
    float getBeamWeaponCycleTime(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].cycleTime; }
    float getBeamWeaponDamage(int index) { if (index < 0 || index >= max_beam_weapons) return 0.0; return beam_weapons[index].damage; }

    int getShieldsFrequency(void){ return shield_frequency; }

    void setBeamWeapon(int index, float arc, float direction, float range, float cycleTime, float damage)
    {
        if (index < 0 || index >= max_beam_weapons)
            return;
        beam_weapons[index].arc = arc;
        beam_weapons[index].direction = direction;
        beam_weapons[index].range = range;
        beam_weapons[index].cycleTime = cycleTime;
        beam_weapons[index].damage = damage;
    }

    void setBeamWeaponTexture(int index, string texture)
    {
        if (index < 0 || index >= max_beam_weapons)
            return;
        beam_weapons[index].beam_texture = texture;
    }

    void setWeaponTubeCount(int amount);
    int getWeaponTubeCount();

    void setRadarTrace(string trace) { radar_trace = trace; }

    void setEngineeringCrew(int number) { engineering_crew = number; }
};

float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency);

string getMissileWeaponName(EMissileWeapons missile);
REGISTER_MULTIPLAYER_ENUM(EMissileWeapons);
REGISTER_MULTIPLAYER_ENUM(EWeaponTubeState);
REGISTER_MULTIPLAYER_ENUM(EMainScreenSetting);
REGISTER_MULTIPLAYER_ENUM(EDockingState);
REGISTER_MULTIPLAYER_ENUM(EScannedState);

string frequencyToString(int frequency);

#endif//SPACE_SHIP_H
