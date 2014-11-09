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
enum EDockingState
{
    DS_NotDocking = 0,
    DS_Docking,
    DS_Docked
};
enum EScannedState
{
    SS_NotScanned,
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

    string templateName;
    string ship_type_name;
    P<ShipTemplate> ship_template;
    float engine_emit_delay;

    ShipSystem systems[SYS_COUNT];

    float targetRotation;
    float impulseRequest;
    float currentImpulse;
    float rotationSpeed;
    float impulseMaxSpeed;

    bool hasWarpdrive;
    int8_t warpRequest;
    float currentWarp;
    float warpSpeedPerWarpLevel;

    bool hasJumpdrive;
    float jumpDistance;
    float jumpDelay;

    int8_t weapon_storage[MW_Count];
    int8_t weapon_storage_max[MW_Count];
    int8_t weaponTubes;
    float tubeLoadTime;
    float tubeRechargeFactor;
    WeaponTube weaponTube[maxWeaponTubes];

    int beam_frequency;
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

    SpaceShip(string multiplayerClassName);

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);

    virtual string getCallSign();
    virtual bool canBeTargeted() { return true; }
    virtual bool hasShield() { return front_shield > (front_shield_max / 50.0) || rear_shield > (rear_shield_max / 50.0); }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type, int frequency=-1);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual void collision(Collisionable* other);

    void loadTube(int tubeNr, EMissileWeapons type);
    void fireTube(int tubeNr);
    void initJump(float distance);
    void requestDock(P<SpaceObject> target);
    void requestUndock();
    void setScanned(bool scanned) { scanned_by_player = scanned ? SS_FullScan : SS_NotScanned; }

    bool hasSystem(ESystem system);
    float getSystemEffectiveness(ESystem system);

    void setShipTemplate(string templateName);

    P<SpaceObject> getTarget();

    bool isDocked() { return docking_state == DS_Docked; }
    int getWeaponStorage(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage[weapon]; }
    int getWeaponStorageMax(EMissileWeapons weapon) { if (weapon == MW_None) return 0; return weapon_storage_max[weapon]; }
    void setWeaponStorage(EMissileWeapons weapon, int amount) { if (weapon == MW_None) return; weapon_storage[weapon] = amount; }
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
