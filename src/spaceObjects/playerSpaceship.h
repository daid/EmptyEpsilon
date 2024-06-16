#ifndef PLAYER_SPACESHIP_H
#define PLAYER_SPACESHIP_H

#include "spaceship.h"
#include "playerInfo.h"
#include "components/player.h"
#include "components/comms.h"
#include <iostream>

class ScanProbe;

class PlayerSpaceship : public SpaceShip
{
public:
    // Overheat subsystem damage rate
    constexpr static float damage_per_second_on_overheat = 0.08f;

    constexpr static int16_t CMD_PLAY_CLIENT_SOUND = 0x0001;
private:
    bool on_new_player_ship_called=false;

public:
    PlayerSpaceship();
    virtual ~PlayerSpaceship();

    // Comms functions
    bool isCommsInactive() { return false; }
    bool isCommsOpening() { return false; }
    bool isCommsBeingHailed() { return false; }
    bool isCommsBeingHailedByGM() { return false; }
    bool isCommsFailed() { return false; }
    bool isCommsBroken() { return false; }
    bool isCommsClosed() { return false; }
    bool isCommsChatOpen() { return false; }
    bool isCommsChatOpenToGM() { return false; }
    bool isCommsChatOpenToPlayer() { return false; }
    bool isCommsScriptOpen() { return false; }
    CommsTransmitter::State getCommsState() { return CommsTransmitter::State::Inactive; }
    float getCommsOpeningDelay() { return 0.0; }
    void setCommsMessage(string message);

    //Spaceship also has functions for these?!?
    void setEnergyLevel(float amount);
    void setEnergyLevelMax(float amount);
    float getEnergyLevel();
    float getEnergyLevelMax();

    void setCanScan(bool enabled) {} //TODO
    bool getCanScan() { return true; } //TODO
    void setCanHack(bool enabled) { } //TODO
    bool getCanHack() { return true; }
    void setCanDock(bool enabled);
    bool getCanDock();
    void setCanCombatManeuver(bool enabled) { } //TODO
    bool getCanCombatManeuver() { return true; } // TODO
    void setCanSelfDestruct(bool enabled) { }  // TODO
    bool getCanSelfDestruct() { return false; } // TODO
    void setCanLaunchProbe(bool enabled) { } // TODO
    bool getCanLaunchProbe() { return true; } // TODO

    void setSelfDestructDamage(float amount) { }  // TODO
    float getSelfDestructDamage() { return 0.0f; }  // TODO
    void setSelfDestructSize(float size) { } // TODO
    float getSelfDestructSize() { return 0.0f; } // TODO

    void setScanProbeCount(int amount) { } //TODO
    int getScanProbeCount() { return 8; }
    void setMaxScanProbeCount(int amount) { } //TODO
    int getMaxScanProbeCount() { return 8; } //TODO

    void onProbeLaunch(ScriptSimpleCallback callback);
    void onProbeLink(ScriptSimpleCallback callback);
    void onProbeUnlink(ScriptSimpleCallback callback);

    void addCustomButton(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback, std::optional<int> order);
    void addCustomInfo(ECrewPosition position, string name, string caption, std::optional<int> order);
    void addCustomMessage(ECrewPosition position, string name, string caption);
    void addCustomMessageWithCallback(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback);
    void removeCustom(string name);

    ShipSystem::Type getBeamSystemTarget();
    string getBeamSystemTargetName();

    // Template function
    virtual void applyTemplateValues() override;

    // Ship status functions
    void setSystemCoolantRequest(ShipSystem::Type system, float request);
    void setMaxCoolant(float coolant);
    float getMaxCoolant() { return 10.0f; } //TODO
    void setAutoCoolant(bool active) {} //TODO
    int getRepairCrewCount();
    void setRepairCrewCount(int amount);
    AlertLevel getAlertLevel() { return AlertLevel::Normal; } // TODO

    // Flow rate controls.
    float getEnergyShieldUsePerSecond() const { return 0.0f; } //TODO
    void setEnergyShieldUsePerSecond(float rate) { } //TODO
    float getEnergyWarpPerSecond() const { return 0.0f; } //TODO
    void setEnergyWarpPerSecond(float rate) {} //TODO

    // Ship's log functions
    void addToShipLog(string message, glm::u8vec4 color);
    void addToShipLogBy(string message, P<SpaceObject> target);

    // Ship's crew functions
    void transferPlayersToShip(P<PlayerSpaceship> other_ship);
    void transferPlayersAtPositionToShip(ECrewPosition position, P<PlayerSpaceship> other_ship);
    bool hasPlayerAtPosition(ECrewPosition position);

    // Ship shields functions
    virtual bool getShieldsActive() override { return true; } //TODO
    void setShieldsActive(bool active) { }

    // Waypoint functions
    int getWaypointCount() { return 0; } //TODO
    glm::vec2 getWaypoint(int index) { return glm::vec2(0, 0); } //TODO

    // Ship control code/password setter
    void setControlCode(string code) { } // TODO

    // Radar function
    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    // Script export function
    virtual string getExportLine() override;
};

#endif//PLAYER_SPACESHIP_H
