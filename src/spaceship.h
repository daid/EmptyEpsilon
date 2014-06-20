#ifndef SPACE_SHIP_H
#define SPACE_SHIP_H

#include "engine.h"
#include "spaceObject.h"
#include "shipTemplate.h"

enum EMissileWeapons
{
    MW_None = -1,
    MW_Homing = 0,
    MW_Nuke,
    MW_Mine,
    MW_EMP,
    MW_Count
};
enum EWeaponTubeState
{
    WTS_Empty,
    WTS_Loading,
    WTS_Loaded,
    WTS_Unloading
};

class BeamWeapon : public sf::NonCopyable
{
public:
    //Beam configuration
    float arc;
    float direction;
    float range;
    float cycleTime;
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
public:
    const static int maxBeamWeapons = 16;
    const static int maxWeaponTubes = 16;
    
    string templateName;
    P<ShipTemplate> shipTemplate;
    
    float targetRotation;
    float impulseRequest;
    float currentImpulse;
    
    bool hasWarpdrive;
    int8_t warpRequest;
    float currentWarp;
    
    bool hasJumpdrive;
    float jumpDistance;
    float jumpDelay;
    
    int8_t weaponStorage[MW_Count];
    int8_t weaponTubes;
    float tubeLoadTime;
    WeaponTube weaponTube[maxWeaponTubes];
    
    BeamWeapon beamWeapons[maxBeamWeapons];
    
    int32_t targetId;

    SpaceShip();
    
    virtual void draw3D();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
    
    virtual bool canBeTargeted() { return true; }
    
    void setShipTemplate(string templateName);
    
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
};

string getMissileWeaponName(EMissileWeapons missile);
static inline sf::Packet& operator << (sf::Packet& packet, const EMissileWeapons& mw)
{
    return packet << int8_t(mw);
}
static inline sf::Packet& operator >> (sf::Packet& packet, EMissileWeapons& mw)
{
    int8_t tmp;
    packet >> tmp;
    mw = EMissileWeapons(tmp);
    return packet;
}
static inline sf::Packet& operator << (sf::Packet& packet, const EWeaponTubeState& mw)
{
    return packet << int8_t(mw);
}
static inline sf::Packet& operator >> (sf::Packet& packet, EWeaponTubeState& mw)
{
    int8_t tmp;
    packet >> tmp;
    mw = EWeaponTubeState(tmp);
    return packet;
}

#endif//SPACE_SHIP_H
