#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"

class PlayerSystem
{
public:
    float health; //1.0-0.0, where 0.0 is fully broken.
    float powerLevel; //0.0-3.0, default 1.0
    float heatLevel; //0.0-1.0, system will damage at 1.0
    float coolantLevel; //0.0-10.0
    
    float powerUserFactor;//const
};

enum EPlayerSystem
{
    PS_Reactor,
    PS_BeamWeapons,
    PS_MissileSystem,
    PS_Maneuver,
    PS_Impulse,
    PS_Warp,
    PS_JumpDrive,
    PS_FrontShield,
    PS_RearShield,
    PS_COUNT
};

class PlayerSpaceship : public SpaceShip
{
    const static float energy_shield_use_per_second = 1.5f;
    const static float energy_per_jump_km = 8.0f;
    const static float energy_per_beam_fire = 3.0f;
    const static float energy_warp_per_second = 1.0f;
    const static float system_heatup_per_second = 0.1f;
public:
    PlayerSystem systems[PS_COUNT];

    float energy_level;
    float hull_damage_indicator;
    P<SpaceShip> scanning_ship; //Server only
    float scanning_delay;
    
    EMainScreenSetting mainScreenSetting;

    PlayerSpaceship();

    void onReceiveCommand(int32_t clientId, sf::Packet& packet);
    void commandTargetRotation(float target);
    void commandImpulse(float target);
    void commandWarp(int8_t target);
    void commandJump(float distance);
    void commandSetTarget(P<SpaceObject> target);
    void commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType);
    void commandUnloadTube(int8_t tubeNumber);
    void commandFireTube(int8_t tubeNumber);
    void commandSetShields(bool enabled);
    void commandMainScreenSetting(EMainScreenSetting mainScreen);
    void commandScan(P<SpaceObject> object);
    void commandSetSystemPower(EPlayerSystem system, float power_level);
    void commandSetSystemCoolant(EPlayerSystem system, float coolant_level);
    
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);

    virtual void update(float delta);
    bool useEnergy(float amount) { if (energy_level >= amount) { energy_level -= amount; return true; } return false; }
};
string getPlayerSystemName(EPlayerSystem system);
REGISTER_MULTIPLAYER_ENUM(EPlayerSystem);

#endif//PLAYER_SPACESHIP_H
