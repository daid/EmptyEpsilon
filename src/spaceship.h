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
    EMissileWeapons typeLoaded;
    EWeaponTubeState state;
    float delay;
};

class SpaceShip : public SpaceObject, public Updatable
{
    const static float shield_recharge_rate = 0.2f;

public:
    string templateName;
    P<ShipTemplate> shipTemplate;
    float engine_emit_delay;
    
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
    float jumpSpeedFactor;
    
    int8_t weapon_storage[MW_Count];
    int8_t weapon_storage_max[MW_Count];
    int8_t weaponTubes;
    float tubeLoadTime;
    float tubeRechargeFactor;
    WeaponTube weaponTube[maxWeaponTubes];
    
    float beamRechargeFactor;
    BeamWeapon beamWeapons[maxBeamWeapons];
    
    float hull_strength, hull_max;
    float front_shield_recharge_factor, rear_shield_recharge_factor;
    bool shields_active;
    float front_shield, rear_shield;
    float front_shield_max, rear_shield_max;
    float front_shield_hit_effect, rear_shield_hit_effect;
    
    int32_t targetId;
    
    bool scanned_by_player;
    
    EDockingState docking_state;
    P<SpaceStation> docking_target; //Server only

    SpaceShip(string multiplayerClassName);
    
    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
    
    virtual string getCallSign();
    virtual bool canBeTargeted() { return true; }
    virtual bool hasShield() { return front_shield > (front_shield_max / 50.0) || rear_shield > (rear_shield_max / 50.0); }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual void collision(Collisionable* other);
    
    void loadTube(int tubeNr, EMissileWeapons type);
    void fireTube(int tubeNr);
    void initJump(float distance);
    void requestDock(P<SpaceStation> target);
    void requestUndock();
    void setScanned(bool value) { scanned_by_player = value; }
    
    bool hasSystem(ESystem system);
    
    void setShipTemplate(string templateName);
    
    P<SpaceObject> getTarget();
};

string getMissileWeaponName(EMissileWeapons missile);
REGISTER_MULTIPLAYER_ENUM(EMissileWeapons);
REGISTER_MULTIPLAYER_ENUM(EWeaponTubeState);
REGISTER_MULTIPLAYER_ENUM(EMainScreenSetting);
REGISTER_MULTIPLAYER_ENUM(EDockingState);

#endif//SPACE_SHIP_H
