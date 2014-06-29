#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"

enum ECommsState
{
    CS_Inactive,
    CS_OpeningChannel,
    CS_ChannelOpen,
    CS_ChannelBroken
};

class PlayerSystem
{
public:
    float health; //1.0-0.0, where 0.0 is fully broken.
    float powerLevel; //0.0-3.0, default 1.0
    float heatLevel; //0.0-1.0, system will damage at 1.0
    float coolantLevel; //0.0-10.0
    
    float powerUserFactor;//const
};

class PlayerSpaceship : public SpaceShip
{
public:
    const static float energy_shield_use_per_second = 1.5f;
    const static float energy_per_jump_km = 8.0f;
    const static float energy_per_beam_fire = 3.0f;
    const static float energy_warp_per_second = 1.0f;
    const static float system_heatup_per_second = 0.1f;
    const static float maxCoolant = 10.0;
    const static float damage_per_second_on_overheat = 0.2;
    const static float max_comm_range = 50000;
    const static float comms_channel_open_time = 2.0;

    PlayerSystem systems[SYS_COUNT];

    float energy_level;
    float hull_damage_indicator;
    float warp_indicator;
    P<SpaceShip> scanning_ship; //Server only
    float scanning_delay;
    
    ECommsState comms_state;
    float comms_open_delay;
    string comms_incomming_message;
    P<SpaceObject> comms_target;    //Server only
    
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
    void commandSetSystemPower(ESystem system, float power_level);
    void commandSetSystemCoolant(ESystem system, float coolant_level);
    void commandDock(P<SpaceStation> station);
    void commandUndock();
    void commandOpenComm(P<SpaceObject> obj);
    void commandCloseComm();
    
    virtual string getCallSign() { return ""; }
    
    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    void setSystemCoolant(ESystem system, float level);

    virtual void update(float delta);
    bool useEnergy(float amount) { if (energy_level >= amount) { energy_level -= amount; return true; } return false; }
};
REGISTER_MULTIPLAYER_ENUM(ECommsState);

#endif//PLAYER_SPACESHIP_H
