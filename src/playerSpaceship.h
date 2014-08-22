#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"
#include "commsScriptInterface.h"
#include "networkRecorder.h"
#include "networkAudioStream.h"
#include <iostream>

enum ECommsState
{
    CS_Inactive,
    CS_OpeningChannel,
    CS_ChannelOpen,
    CS_ChannelOpenPlayer,
    CS_ChannelFailed,
    CS_ChannelBroken
};

class PlayerSystem
{
public:
    float health; //1.0-0.0, where 0.0 is fully broken.
    float power_level; //0.0-3.0, default 1.0
    float heat_level; //0.0-1.0, system will damage at 1.0
    float coolant_level; //0.0-10.0

    float power_user_factor;//const
};

class PlayerCommsReply
{
public:
    int32_t id; //server only
    string message;
};

class PlayerSpaceship : public SpaceShip
{
public:
    const static float energy_shield_use_per_second = 1.5f;
    const static float energy_per_jump_km = 8.0f;
    const static float energy_per_beam_fire = 3.0f;
    const static float energy_warp_per_second = 1.0f;
    const static float system_heatup_per_second = 0.1f;
    const static float max_coolant = 10.0;
    const static float damage_per_second_on_overheat = 0.2;
    const static float shield_calibration_time = 10.0f;
    const static float max_comm_range = 50000;
    const static float comms_channel_open_time = 2.0;
    const static int max_comms_reply_count = 16;

    PlayerSystem systems[SYS_COUNT];
    NetworkRecorder network_recorder;
    NetworkAudioStream network_audio_stream;
    float energy_level;
    float hull_damage_indicator;
    float warp_indicator;
    P<SpaceShip> scanning_ship; //Server only
    float scanning_delay;
    float shield_calibration_delay;
    bool auto_repair_enabled;

    ECommsState comms_state;
    float comms_open_delay;
    string comms_incomming_message;
    P<SpaceObject> comms_target;    //Server only
    int8_t comms_reply_count;
    PlayerCommsReply comms_reply[max_comms_reply_count];
    CommsScriptInterface comms_script_interface;  //Server only

    EMainScreenSetting main_screen_setting;

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
    void commandOpenTextComm(P<SpaceObject> obj);
    void commandCloseTextComm();
    void commandOpenVoiceComm(P<SpaceObject> obj);
    void commandCloseVoiceComm();
    void commandSendComm(int8_t index);
    void commandSendCommPlayer(string message);
    void commandSetAutoRepair(bool enabled);
    void commandSetBeamFrequency(int frequency);
    void commandSetShieldFrequency(int frequency);

    virtual string getCallSign() { return ""; }

    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual void hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
    void setSystemCoolant(ESystem system, float level);

    virtual void update(float delta);
    bool useEnergy(float amount) { if (energy_level >= amount) { energy_level -= amount; return true; } return false; }

    void setCommsMessage(string message);
    void addCommsReply(int32_t id, string message);
};
REGISTER_MULTIPLAYER_ENUM(ECommsState);

#endif//PLAYER_SPACESHIP_H
