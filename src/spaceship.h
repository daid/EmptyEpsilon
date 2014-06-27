#ifndef SPACE_SHIP_H
#define SPACE_SHIP_H

#include "engine.h"
#include "spaceObject.h"
#include "shipTemplate.h"

enum EWeaponTubeState
{
    WTS_Empty,
    WTS_Loading,
    WTS_Loaded,
    WTS_Unloading
};
enum EMainScreenSetting
{
    MSS_Front,
    MSS_Back,
    MSS_Left,
    MSS_Right,
    MSS_Tactical,
    MSS_LongRange
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
<<<<<<< HEAD
    //TODO: Getting statistics from some external file (location of beam weapons, shields, hull, etc).
    //This will make adding multiple ships a *lot* easier.
public:
    const static int maxBeamWeapons = 16;
    const static int maxWeaponTubes = 16;

    float targetRotation;
    float impulseRequest;
    float currentImpulse;

    bool hasWarpdrive;
    int8_t warpRequest;
    float currentWarp;

    bool hasJumpdrive;
    float jumpDistance;
    float jumpDelay;

=======
    const static float shield_recharge_rate = 0.2f;

public:
    string templateName;
    P<ShipTemplate> shipTemplate;
    
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
    
    int8_t weaponStorage[MW_Count];
    int8_t weaponStorageMax[MW_Count];
>>>>>>> origin/master
    int8_t weaponTubes;
    float tubeLoadTime;
    float tubeRechargeFactor;
    WeaponTube weaponTube[maxWeaponTubes];
    
    float beamRechargeFactor;
    BeamWeapon beamWeapons[maxBeamWeapons];
<<<<<<< HEAD

=======
    
    float hull_strength, hull_max;
    float front_shield_recharge_factor, rear_shield_recharge_factor;
    bool shields_active;
    float front_shield, rear_shield;
    float front_shield_max, rear_shield_max;
    float front_shield_hit_effect, rear_shield_hit_effect;
    
>>>>>>> origin/master
    int32_t targetId;
    
    bool scanned_by_player;

<<<<<<< HEAD
    SpaceShip();

=======
    SpaceShip(string multiplayerClassName);
    
>>>>>>> origin/master
    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
<<<<<<< HEAD

    P<SpaceObject> getTarget();

    void onReceiveCommand(int32_t clientId, sf::Packet& packet);
    void commandTargetRotation(float target);
    void commandImpulse(float target);
    void commandWarp(int8_t target);
    void commandJump(float distance);
    void commandSetTarget(P<SpaceObject> target);
    void commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType);
    void commandUnloadTube(int8_t tubeNumber);
    void commandFireTube(int8_t tubeNumber);
=======
    
    virtual bool canBeTargeted() { return true; }
    virtual bool hasShield() { return front_shield > (front_shield_max / 50.0) || rear_shield > (rear_shield_max / 50.0); }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    
    void loadTube(int tubeNr, EMissileWeapons type);
    void fireTube(int tubeNr);
    void initJump(float distance);
    
    bool hasSystem(ESystem system);
    
    void setShipTemplate(string templateName);
    
    P<SpaceObject> getTarget();
>>>>>>> origin/master
};

string getMissileWeaponName(EMissileWeapons missile);
REGISTER_MULTIPLAYER_ENUM(EMissileWeapons);
REGISTER_MULTIPLAYER_ENUM(EWeaponTubeState);
REGISTER_MULTIPLAYER_ENUM(EMainScreenSetting);

#endif//SPACE_SHIP_H
