#ifndef PLAYER_INFO_H
#define PLAYER_INFO_H

#include "multiplayer.h"
#include "components/player.h"
#include "systems/shipsystemssystem.h"
#include "missileWeaponData.h"
#include "crewPosition.h"


class PlayerInfo;
class RenderLayer;
extern P<PlayerInfo> my_player_info;
extern sp::ecs::Entity my_spaceship;
extern PVector<PlayerInfo> player_info_list;

class PlayerInfo : public MultiplayerObject
{
public:
    int32_t client_id;

    std::vector<CrewPositions> crew_positions;
    uint32_t main_screen = 0;
    uint32_t main_screen_control = 0;
    sp::ecs::Entity ship;
    string name;
    string last_ship_password;

    PlayerInfo();

    void reset();

    bool hasPosition(CrewPosition cp);
    bool isOnlyMainScreen(int monitor_index);

    void commandTargetRotation(float target);
    void commandTurnSpeed(float turnSpeed);
    void commandImpulse(float target);
    void commandWarp(int target);
    void commandJump(float distance);
    void commandAbortJump();
    void commandSetTarget(sp::ecs::Entity target);
    void commandSetScienceLink(sp::ecs::Entity probe);
    void commandClearScienceLink();
    void commandLoadTube(uint32_t tubeNumber, EMissileWeapons missileType);
    void commandUnloadTube(uint32_t tubeNumber);
    void commandFireTube(uint32_t tubeNumber, float missile_target_angle);
    void commandFireTubeAtTarget(uint32_t tubeNumber, sp::ecs::Entity target);
    void commandSetShields(bool enabled);
    void commandMainScreenSetting(MainScreenSetting mainScreen);
    void commandMainScreenOverlay(MainScreenOverlay mainScreen);
    void commandScan(sp::ecs::Entity object);
    void commandSetSystemPowerRequest(ShipSystem::Type system, float power_level);
    void commandSetSystemCoolantRequest(ShipSystem::Type system, float coolant_level);
    void commandDock(sp::ecs::Entity station);
    void commandUndock();
    void commandAbortDock();
    void commandOpenTextComm(sp::ecs::Entity obj);
    void commandCloseTextComm();
    void commandAnswerCommHail(bool awnser);
    void commandSendComm(uint8_t index);
    void commandSendCommPlayer(string message);
    void commandSetAutoRepair(bool enabled);
    void commandSetBeamFrequency(int32_t frequency);
    void commandSetBeamSystemTarget(ShipSystem::Type system);
    void commandSetShieldFrequency(int32_t frequency);
    void commandAddWaypoint(glm::vec2 position);
    void commandRemoveWaypoint(int32_t index);
    void commandMoveWaypoint(int32_t index, glm::vec2 position);
    void commandActivateSelfDestruct();
    void commandCancelSelfDestruct();
    void commandConfirmDestructCode(int8_t index, uint32_t code);
    void commandCombatManeuverBoost(float amount);
    void commandCombatManeuverStrafe(float strafe);
    void commandLaunchProbe(glm::vec2 target_position);
    void commandScanDone();
    void commandScanCancel();
    void commandSetAlertLevel(AlertLevel level);
    void commandHackingFinished(sp::ecs::Entity target, ShipSystem::Type target_system);
    void commandCustomFunction(string name);

    void commandSetCrewPosition(int monitor_index, CrewPosition position, bool active);
    void commandSetShip(sp::ecs::Entity entity);
    void commandSetMainScreen(int monitor_index, bool enabled);
    void commandSetMainScreenControl(int monitor_index, bool control);
    void commandSetName(const string& name);

    void commandCrewSetTargetPosition(sp::ecs::Entity crew, glm::ivec2 target);

    virtual void onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet) override;

    void spawnUI(int monitor_index, RenderLayer* render_layer);

    static bool hasPlayerAtPosition(sp::ecs::Entity entity, CrewPosition position);
};

string getCrewPositionName(CrewPosition position);
string getCrewPositionIcon(CrewPosition position);

#endif//PLAYER_INFO_H
