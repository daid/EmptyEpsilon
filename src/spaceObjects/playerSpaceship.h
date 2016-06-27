#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"
#include "commsScriptInterface.h"
#include "playerInfo.h"
#include <iostream>

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
    CS_ChannelBroken,
    CS_ChannelClosed
};

enum EAlertLevel
{
    AL_Normal,
    AL_YellowAlert,
    AL_RedAlert,
    AL_MAX
};

class PlayerSpaceship : public SpaceShip
{
public:
    constexpr static float energy_shield_use_per_second = 18.75f;
    constexpr static float energy_warp_per_second = 1.0f;
    constexpr static float system_heatup_per_second = 0.05f;
    constexpr static float system_power_level_change_per_second = 0.3;
    constexpr static float system_coolant_level_change_per_second = 1.2;
    constexpr static float max_coolant = 10.0;
    constexpr static float damage_per_second_on_overheat = 0.08f;
    constexpr static float shield_calibration_time = 25.0f;
    constexpr static float comms_channel_open_time = 2.0;
    constexpr static int max_self_destruct_codes = 3;
    constexpr static int max_scan_probes = 8;
    constexpr static float scan_probe_charge_time = 10.0f;
    constexpr static float max_scanning_delay = 6.0;

    class ShipLogEntry
    {
    public:
        string prefix;
        string text;
        sf::Color color;

        ShipLogEntry() {}
        ShipLogEntry(string prefix, string text, sf::Color color)
        : prefix(prefix), text(text), color(color) {}

        bool operator!=(const ShipLogEntry& e) { return prefix != e.prefix || text != e.text || color != e.color; }
    };

    float hull_damage_indicator;
    float jump_indicator;
    P<SpaceObject> scanning_target; //Server only
    float scanning_delay;
    int scanning_complexity;
    int scanning_depth;
    float shield_calibration_delay;
    bool auto_repair_enabled;
    bool auto_coolant_enabled;
    bool shields_active;

private:
    ECommsState comms_state;
    float comms_open_delay;
    string comms_target_name;
    string comms_incomming_message;
    P<SpaceObject> comms_target;    //Server only
    std::vector<int> comms_reply_id;
    std::vector<string> comms_reply_message;
    CommsScriptInterface comms_script_interface;  //Server only

    std::vector<ShipLogEntry> ships_log;

public:
    std::vector<sf::Vector2f> waypoints;
    int scan_probe_stock;
    float scan_probe_recharge;

    EMainScreenSetting main_screen_setting;
    EMainScreenOverlay main_screen_overlay;

    bool activate_self_destruct;
    uint32_t self_destruct_code[max_self_destruct_codes];
    bool self_destruct_code_confirmed[max_self_destruct_codes];
    ECrewPosition self_destruct_code_entry_position[max_self_destruct_codes];
    ECrewPosition self_destruct_code_show_position[max_self_destruct_codes];
    float self_destruct_countdown;

    EAlertLevel alert_level;

    int32_t linked_science_probe_id;

    PlayerSpaceship();

    bool isCommsInactive() { return comms_state == CS_Inactive; }
    bool isCommsOpening() { return comms_state == CS_OpeningChannel; }
    bool isCommsBeingHailed() { return comms_state == CS_BeingHailed || comms_state == CS_BeingHailedByGM; }
    bool isCommsBeingHailedByGM() { return comms_state == CS_BeingHailedByGM; }
    bool isCommsFailed() { return comms_state == CS_ChannelFailed; }
    bool isCommsBroken() { return comms_state == CS_ChannelBroken; }
    bool isCommsClosed() { return comms_state == CS_ChannelClosed; }
    bool isCommsChatOpen() { return comms_state == CS_ChannelOpenPlayer || comms_state == CS_ChannelOpenGM; }
    bool isCommsChatOpenToGM() { return comms_state == CS_ChannelOpenGM; }
    bool isCommsChatOpenToPlayer() { return comms_state == CS_ChannelOpenPlayer; }
    bool isCommsScriptOpen() { return comms_state == CS_ChannelOpen; }
    ECommsState getCommsState() { return comms_state; }
    float getCommsOpeningDelay() { return comms_open_delay; }
    const std::vector<string>& getCommsReplyOptions() const { return comms_reply_message; }
    P<SpaceObject> getCommsTarget() { return comms_target; }
    const string& getCommsTargetName() { return comms_target_name; }
    const string& getCommsIncommingMessage() { return comms_incomming_message; }
    bool hailCommsByGM(string target_name);
    bool hailByObject(P<SpaceObject> object, string opening_message);
    void setCommsMessage(string message);
    void addCommsIncommingMessage(string message);
    void addCommsOutgoingMessage(string message);
    void addCommsReply(int32_t id, string message);
    void closeComms();

    void onReceiveClientCommand(int32_t client_id, sf::Packet& packet);
    void commandTargetRotation(float target);
    void commandImpulse(float target);
    void commandWarp(int8_t target);
    void commandJump(float distance);
    void commandSetTarget(P<SpaceObject> target);
    void commandSetScienceLink(int32_t id);
    void commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType);
    void commandUnloadTube(int8_t tubeNumber);
    void commandFireTube(int8_t tubeNumber, float missile_target_angle);
    void commandSetShields(bool enabled);
    void commandMainScreenSetting(EMainScreenSetting mainScreen);
    void commandMainScreenOverlay(EMainScreenOverlay mainScreen);
    void commandScan(P<SpaceObject> object);
    void commandSetSystemPowerRequest(ESystem system, float power_level);
    void commandSetSystemCoolantRequest(ESystem system, float coolant_level);
    void commandDock(P<SpaceObject> station);
    void commandUndock();
    void commandAbortDock();
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
    void commandMoveWaypoint(int32_t index, sf::Vector2f position);
    void commandActivateSelfDestruct();
    void commandCancelSelfDestruct();
    void commandConfirmDestructCode(int8_t index, uint32_t code);
    void commandCombatManeuverBoost(float amount);
    void commandCombatManeuverStrafe(float strafe);
    void commandLaunchProbe(sf::Vector2f target_position);
    void commandScanDone();
    void commandScanCancel();
    void commandSetAlertLevel(EAlertLevel level);

    virtual void applyTemplateValues() override;

    virtual void executeJump(float distance) override;
    virtual void takeHullDamage(float damage_amount, DamageInfo& info) override;
    void setSystemCoolantRequest(ESystem system, float request);

    virtual void update(float delta) override;
    virtual bool useEnergy(float amount) override;
    virtual void addHeat(ESystem system, float amount) override;

    float getNetPowerUsage();

    void addToShipLog(string message, sf::Color color);
    void addToShipLogBy(string message, P<SpaceObject> target);
    const std::vector<ShipLogEntry>& getShipsLog() const;
    
    void transferPlayersToShip(P<PlayerSpaceship> other_ship);
    void transferPlayersAtPositionToShip(ECrewPosition position, P<PlayerSpaceship> other_ship);
    bool hasPlayerAtPosition(ECrewPosition position);

    virtual bool getShieldsActive() override { return shields_active; }
    void setShieldsActive(bool active) { shields_active = active; }
    
    void setAutoCoolant(bool active) { auto_coolant_enabled = active; }

    int getWaypointCount() { return waypoints.size(); }
    sf::Vector2f getWaypoint(int index) { if (index > 0 && index <= int(waypoints.size())) return waypoints[index - 1]; return sf::Vector2f(0, 0); }

    int getRepairCrewCount();
    void setRepairCrewCount(int amount);

    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;

    EAlertLevel getAlertLevel() { return alert_level; }

    virtual string getExportLine();
};
REGISTER_MULTIPLAYER_ENUM(ECommsState);
template<> int convert<EAlertLevel>::returnType(lua_State* L, EAlertLevel l);
REGISTER_MULTIPLAYER_ENUM(EAlertLevel);

string alertLevelToString(EAlertLevel level);

#ifdef _MSC_VER
#include "playerSpaceship.hpp"
#endif /* _MSC_VER */

#endif//PLAYER_SPACESHIP_H
