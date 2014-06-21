#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"

class PlayerSpaceship : public SpaceShip
{
    const static float energy_recharge_per_second = 1.0f;
    const static float energy_shield_use_per_second = 1.5f;
    const static float energy_per_jump_km = 8.0f;
    const static float energy_per_beam_fire = 3.0f;
    const static float energy_warp_per_second = 1.0;

public:
    float energy_level;
    float hull_damage_indicator;
    
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
    
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);

    virtual void update(float delta);
    bool useEnergy(float amount) { if (energy_level >= amount) { energy_level -= amount; return true; } return false; }
};

#endif//PLAYER_SPACESHIP_H
