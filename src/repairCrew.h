#ifndef REPAIR_CREW_H
#define REPAIR_CREW_H

#include "engine.h"
#include "spaceObjects/playerSpaceship.h"

enum ERepairCrewAction
{
    RC_Idle,
    RC_Move
};
enum ERepairCrewDirection
{
    RC_None,
    RC_Up,
    RC_Down,
    RC_Left,
    RC_Right
};

class RepairCrew : public MultiplayerObject, public Updatable
{
    static constexpr float move_speed = 2.0;
    static constexpr float repair_per_second = 0.007;
public:
    glm::vec2 position{0,0};
    glm::ivec2 target_position{0,0};
    ERepairCrewAction action;
    ERepairCrewDirection direction;
    float action_delay;
    sp::ecs::Entity ship;

    bool selected; //TODO: This should not be tracked here but in the GUI.

    RepairCrew();
    virtual ~RepairCrew();

    virtual void onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet) override;
    void commandSetTargetPosition(glm::ivec2 position);

    virtual void update(float delta) override;
private:
    bool isTargetPositionTaken(glm::ivec2 position);
};
PVector<RepairCrew> getRepairCrewFor(sp::ecs::Entity ship);

#endif//REPAIR_CREW_H
