#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"
#include "commsScriptInterface.h"
#include "networkRecorder.h"
#include "networkAudioStream.h"
#include <iostream>

enum ECrewPosition
{
    helmsOfficer,
    weaponsOfficer,
    engineering,
    scienceOfficer,
    commsOfficer,
    tacticalOfficer,    //helms+weapons-shields
    engineeringAdvanced,//engineering+shields
    operationsOfficer, //science+comms
    singlePilot,
    max_crew_positions
};

enum ECommsState
{
    CS_Inactive,
    CS_OpeningChannel,
    CS_BeingHailed,
    CS_BeingHailedByGM,
    CS_ChannelOpen,
    CS_ChannelOpenPlayer,
    CS_ChannelOpenGM,
    CS_ChannelFailed,
    CS_ChannelBroken
};

class PlayerSpaceship : public SpaceShip
{
public:
    constexpr static float energy_shield_use_per_second = 1.5f;
    constexpr static float energy_per_jump_km = 8.0f;
    constexpr static float energy_per_beam_fire = 3.0f;
    constexpr static float energy_warp_per_second = 1.0f;
    constexpr static float system_heatup_per_second = 0.05f;
    constexpr static float max_coolant = 10.0;
    constexpr static float damage_per_second_on_overheat = 0.05;
    constexpr static float shield_calibration_time = 20.0f;
    constexpr static float comms_channel_open_time = 2.0;
    constexpr static int max_comms_reply_count = 16;
    constexpr static int max_self_destruct_codes = 3;
    constexpr static float heat_per_jump = 0.25;
    constexpr static float heat_per_beam_fire = 0.02;
    constexpr static float heat_per_combat_maneuver_boost = 0.2;
    constexpr static float heat_per_combat_maneuver_strafe = 0.2;
    constexpr static float heat_per_warp = 0.02;
    constexpr static int max_scan_probes = 10;
    constexpr static float max_scanning_delay = 6.0;

    NetworkRecorder network_recorder;
    NetworkAudioStream network_audio_stream;
    float hull_damage_indicator;
    float jump_indicator;
    P<SpaceShip> scanning_ship; //Server only
    float scanning_delay;
    float shield_calibration_delay;
    bool auto_repair_enabled;

    ECommsState comms_state;
    float comms_open_delay;
    string comms_incomming_message;
    P<SpaceObject> comms_target;    //Server only
    std::vector<int> comms_reply_id;
    std::vector<string> comms_reply_message;
    CommsScriptInterface comms_script_interface;  //Server only
    std::vector<sf::Vector2f> waypoints;
    int scan_probe_stock;

    EMainScreenSetting main_screen_setting;

    bool activate_self_destruct;
    uint32_t self_destruct_code[max_self_destruct_codes];
    bool self_destruct_code_confirmed[max_self_destruct_codes];
    ECrewPosition self_destruct_code_entry_position[max_self_destruct_codes];
    ECrewPosition self_destruct_code_show_position[max_self_destruct_codes];

    PlayerSpaceship();

    void onReceiveClientCommand(int32_t client_id, sf::Packet& packet);
    void commandTargetRotation(float target);
    void commandImpulse(float target);
    void commandWarp(int8_t target);
    void commandJump(float distance);
    void commandSetTarget(P<SpaceObject> target);
    void commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType);
    void commandUnloadTube(int8_t tubeNumber);
    void commandFireTube(int8_t tubeNumber, float missile_target_angle);
    void commandSetShields(bool enabled);
    void commandMainScreenSetting(EMainScreenSetting mainScreen);
    void commandScan(P<SpaceObject> object);
    void commandSetSystemPower(ESystem system, float power_level);
    void commandSetSystemCoolant(ESystem system, float coolant_level);
    void commandDock(P<SpaceObject> station);
    void commandUndock();
    void commandOpenTextComm(P<SpaceObject> obj);
    void commandCloseTextComm();
    void commandAnswerCommHail(bool awnser);
    void commandSendComm(uint8_t index);
    void commandSendCommPlayer(string message);
    void commandSetAutoRepair(bool enabled);
    void commandSetBeamFrequency(int32_t frequency);
    void commandSetBeamSystemTarget(ESystem system);
    void commandSetShieldFrequency(int32_t frequency);
    void commandAddWaypoint(sf::Vector2f position);
    void commandRemoveWaypoint(int32_t index);
    void commandActivateSelfDestruct();
    void commandCancelSelfDestruct();
    void commandConfirmDestructCode(int8_t index, uint32_t code);
    void commandCombatManeuverBoost(float amount);
    void commandCombatManeuverStrafe(float strafe);
    void commandLaunchProbe(sf::Vector2f target_position);

    virtual string getCallSign() { return "PL" + string(getMultiplayerId()); }

    virtual void setShipTemplate(string template_name);

    virtual void executeJump(float distance);
    virtual void fireBeamWeapon(int index, P<SpaceObject> target);
    virtual void takeHullDamage(float damage_amount, DamageInfo& info);
    void setSystemCoolant(ESystem system, float level);

    virtual void update(float delta);
    bool useEnergy(float amount) { if (energy_level >= amount) { energy_level -= amount; return true; } return false; }
    void addHeat(ESystem system, float amount);

    float getNetPowerUsage();

    void setCommsMessage(string message);
    void addCommsReply(int32_t id, string message);
    int getWaypointCount() { return waypoints.size(); }
    sf::Vector2f getWaypoint(int index) { if (index > 0 && index <= int(waypoints.size())) return waypoints[index - 1]; return sf::Vector2f(0, 0); }
};
REGISTER_MULTIPLAYER_ENUM(ECommsState);
REGISTER_MULTIPLAYER_ENUM(ECrewPosition);

#endif//PLAYER_SPACESHIP_H
