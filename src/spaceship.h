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
    
    int8_t weaponStorage[MW_Count];
    int8_t weaponStorageMax[MW_Count];
    int8_t weaponTubes;
    float tubeLoadTime;
    WeaponTube weaponTube[maxWeaponTubes];
    
    BeamWeapon beamWeapons[maxBeamWeapons];
    
    float hull_strength, hull_max;
    bool shields_active;
    float front_shield, rear_shield;
    float front_shield_max, rear_shield_max;
    float front_shield_hit_effect, rear_shield_hit_effect;
    
    int32_t targetId;
    
    bool scanned_by_player;

    SpaceShip(string multiplayerClassName);
    
    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
    
    virtual bool canBeTargeted() { return true; }
    virtual bool hasShield() { return front_shield > (front_shield_max / 50.0) || rear_shield > (rear_shield_max / 50.0); }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    
    void loadTube(int tubeNr, EMissileWeapons type);
    void fireTube(int tubeNr);
    void initJump(float distance);
    
    void setShipTemplate(string templateName);
    
    P<SpaceObject> getTarget();
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
static inline sf::Packet& operator << (sf::Packet& packet, const EMainScreenSetting& e)
{
    return packet << int8_t(e);
}
static inline sf::Packet& operator >> (sf::Packet& packet, EMainScreenSetting& e)
{
    int8_t tmp;
    packet >> tmp;
    e = EMainScreenSetting(tmp);
    return packet;
}

#endif//SPACE_SHIP_H
