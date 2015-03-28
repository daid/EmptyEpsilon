#ifndef SPACE_SHIP_H
#define SPACE_SHIP_H

#include "engine.h"
#include "spaceObject.h"
#include "shipTemplate.h"
#include "spaceStation.h"

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
enum ECombatManeuver
{
    CM_Boost,
    CM_StrafeLeft,
    CM_StrafeRight,
    CM_Turn
};
template<> void convert<ECombatManeuver>::param(lua_State* L, int& idx, ECombatManeuver& cm);

class ShipSystem
{
public:
    float health; //1.0-0.0, where 0.0 is fully broken.
    float power_level; //0.0-3.0, default 1.0
    float heat_level; //0.0-1.0, system will damage at 1.0
    float coolant_level; //0.0-10.0
};

class BeamWeapon : public sf::NonCopyable
{
public:
    //Beam configuration
    float arc;
    float direction;
    float range;
    float cycleTime;
    float damage;//Server side only
    //Beam runtime state
    float cooldown;
};
class WeaponTube : public sf::NonCopyable
{
public:
    EMissileWeapons type_loaded;
    EWeaponTubeState state;
    float delay;
};

class SpaceShip : public SpaceObject, public Updatable
{
    const static float shield_recharge_rate = 0.2f;
public:
    const static int max_frequency = 20;
    const static float max_combat_maneuver_delay = 14.0f;

    string template_name;
    string ship_type_name;
    P<ShipTemplate> ship_template;
    string ship_callsign;
    float engine_emit_delay;

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
     * [output] Time in seconds until combat maneuver is active again
     */
    float combat_maneuver_delay;
    ECombatManeuver combat_maneuver;
    float combat_maneuver_active;

    bool has_jump_drive;      //[config]
    float jump_distance;     //[output]
    float jump_delay;        //[output]

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

    float hull_strength, hull_max;
    bool shields_active;
    int shield_frequency;
    float front_shield, rear_shield;
    float front_shield_max, rear_shield_max;
    float front_shield_hit_effect, rear_shield_hit_effect;

    int32_t target_id;

    /*!
     * TODO; Needs to be fixed for multiplayer!
     */
    EScannedState scanned_by_player;

    EDockingState docking_state;
    P<SpaceObject> docking_target; //Server only
    sf::Vector2f docking_offset; //Server only

    SpaceShip(string multiplayerClassName, float multiplayer_significant_range=-1);

    virtual void draw3D();
    virtual void draw3DTransparent();

    /*!
     * Draw this ship on the radar.
     */
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual void update(float delta);

    /*!
     * Get the call sign of this ship.
     */
    virtual string getCallSign();

    /*!
     * Check if the ship can be targeted.
     */
    virtual bool canBeTargeted() { return true; }

    /*!
     * Check if spaceship has a shield
     */
    virtual bool hasShield() { return front_shield > (front_shield_max / 50.0) || rear_shield > (rear_shield_max / 50.0); }

    /*!
     * Spaceship takes damage
     * \param damage_amount Damage to be delt.
     * \param info Information about damage type (usefull for damage reduction, etc)
     */
    virtual void takeDamage(float damage_amount, DamageInfo& info);

    /*!
     * Spaceship takes damage directly on hull.
     * This is used when shields are down or by weapons that ignore shields.
     * \param damage_amount Damage to be delt.
     * \param info Information about damage type (usefull for damage reduction, etc)
     */
    virtual void takeHullDamage(float damage_amount, DamageInfo& info);

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

    virtual void collide(Collisionable* other);

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
    void setScanned(bool scanned) { scanned_by_player = scanned ? SS_FullScan : SS_NotScanned; }

    /*!
     * Activate a certain combat maneuver (and start 'reload' timer)
     */
    void activateCombatManeuver(ECombatManeuver maneuver);
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
    virtual void setShipTemplate(string template_names);

    P<SpaceObject> getTarget();

    bool isDocked(P<SpaceObject> target) { return docking_state == DS_Docked && docking_target == target; }
    int getWeaponStorage(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage[weapon]; }
    int getWeaponStorageMax(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage_max[weapon]; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage[weapon] = amount; }
    float getHull() { return hull_strength; }
    float getHullMax() { return hull_max; }
    float getFrontShield() { return front_shield; }
    float getFrontShieldMax() { return front_shield_max; }
    float getRearShield() { return rear_shield; }
    float getRearShieldMax() { return rear_shield_max; }
    bool getShieldsActive() { return shields_active; }

    void setHull(float amount) { hull_strength = amount; }
    void setHullMax(float amount) { hull_max = amount; }
    void setFrontShield(float amount) { front_shield = amount; }
    void setFrontShieldMax(float amount) { front_shield_max = amount; }
    void setRearShield(float amount) { rear_shield = amount; }
    void setRearShieldMax(float amount) { rear_shield_max = amount; }
    void setShieldsActive(bool enabled) { shields_active = enabled; }
    void setJumpDrive(bool enabled) { hasJumpdrive = enabled; }
    void setImpulseRequest(float impulse) {impulseRequest = impulse; }
    void setWarpRequest(int warp) {warpRequest = warp; }

    void LoadTube(int tubeNr, EMissileWeapons type) { loadTube(tubeNr, type); }
    void FireTube(int tubeNr, float target_angle) {fireTube(tubeNr, target_angle); }
    void InitJump(float distance) { initJump(distance); }

    //virtual void takeDamage(float damageAmount, DamageInfo& info);
    //virtual void hullDamage(float damageAmount, DamageInfo& info);
};

float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency);

string getMissileWeaponName(EMissileWeapons missile);
REGISTER_MULTIPLAYER_ENUM(EMissileWeapons);
REGISTER_MULTIPLAYER_ENUM(EWeaponTubeState);
REGISTER_MULTIPLAYER_ENUM(EMainScreenSetting);
REGISTER_MULTIPLAYER_ENUM(EDockingState);
REGISTER_MULTIPLAYER_ENUM(EScannedState);
REGISTER_MULTIPLAYER_ENUM(ECombatManeuver);

string frequencyToString(int frequency);

#endif//SPACE_SHIP_H
