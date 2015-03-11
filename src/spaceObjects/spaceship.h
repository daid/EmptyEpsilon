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

    string templateName;
    string ship_type_name;
    P<ShipTemplate> ship_template;
    string ship_callsign;
    float engine_emit_delay;

    ShipSystem systems[SYS_COUNT];

    float targetRotation;
    float impulseRequest;
    float currentImpulse;
    float rotationSpeed;
    float impulseMaxSpeed;
    float impulseAcceleration;

    bool hasWarpdrive;
    int8_t warpRequest;
    float currentWarp;
    float warpSpeedPerWarpLevel;
    float combat_maneuver_delay;
    ECombatManeuver combat_maneuver;
    float combat_maneuver_active;

    bool hasJumpdrive;
    float jumpDistance;
    float jumpDelay;

    int8_t weapon_storage[MW_Count];
    int8_t weapon_storage_max[MW_Count];
    int8_t weapon_tubes;
    float tubeLoadTime;
    float tubeRechargeFactor;
    WeaponTube weaponTube[maxWeaponTubes];

    int beam_frequency;
    ESystem beam_system_target;
    BeamWeapon beamWeapons[maxBeamWeapons];

    float hull_strength, hull_max;
    bool shields_active;
    int shield_frequency;
    float front_shield, rear_shield;
    float front_shield_max, rear_shield_max;
    float front_shield_hit_effect, rear_shield_hit_effect;

    int32_t targetId;

    EScannedState scanned_by_player; //Is this really smart with multiple players? No, does not really work well with multiple ships, and causes lots of problems with PvP.

    EDockingState docking_state;
    P<SpaceObject> docking_target; //Server only
    sf::Vector2f docking_offset; //Server only

    SpaceShip(string multiplayerClassName, float multiplayer_significant_range=-1);

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);

    virtual string getCallSign();
    virtual bool canBeTargeted() { return true; }
    virtual bool hasShield() { return front_shield > (front_shield_max / 50.0) || rear_shield > (rear_shield_max / 50.0); }
    virtual void takeDamage(float damageAmount, DamageInfo& info);
    virtual void hullDamage(float damageAmount, DamageInfo& info);
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual void collision(Collisionable* other);

    void loadTube(int tubeNr, EMissileWeapons type);
    void fireTube(int tubeNr, float target_angle);
    void initJump(float distance);
    void requestDock(P<SpaceObject> target);
    void requestUndock();
    void setScanned(bool scanned) { scanned_by_player = scanned ? SS_FullScan : SS_NotScanned; }
    void activateCombatManeuver(ECombatManeuver maneuver);

    bool hasSystem(ESystem system);
    float getSystemEffectiveness(ESystem system);

    virtual void setShipTemplate(string templateName);

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
