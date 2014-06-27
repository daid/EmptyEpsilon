#ifndef SPACE_SHIP_H
#define SPACE_SHIP_H

#include "engine.h"
#include "spaceObject.h"

enum EMissileWeapons
{
    MW_None = -1,
    MW_Homing = 0,
    MW_Nuke,
    MW_Mine,
    MW_EMP,
    MW_Count
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
    float loadingDelay;
};

class SpaceShip : public SpaceObject, public Updatable
{
    //TODO: Getting statistics from some external file (location of beam weapons, shields, hull, etc).
    //This will make adding multiple ships a *lot* easier.
public:
    const static int max_beam_weapons = 16;
    const static int max_weapon_tubes = 16;

    float target_rotation;
    float impulse_request;
    float current_impulse;

    bool has_warp_drive;
    int8_t warp_request;
    float current_warp;

    bool has_jump_drive;
    float jump_distance;
    float jump_delay;

    int8_t weapon_tubes;
    WeaponTube weapon_tube[max_weapon_tubes];
    BeamWeapon beam_weapons[max_beam_weapons];

    int32_t target_id;

    SpaceShip();

    virtual void draw3D();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale);
    virtual void update(float delta);

    P<SpaceObject> getTarget();

    void onReceiveCommand(int32_t client_id, sf::Packet& packet);
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

#endif//SPACE_SHIP_H
