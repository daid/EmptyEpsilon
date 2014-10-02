#ifndef REPAIR_CREW_H
#define REPAIR_CREW_H

#include "engine.h"
#include "playerSpaceship.h"

enum ERepairCrewAction
{
    RC_Idle,
    RC_MoveLeft,
    RC_MoveRight,
    RC_MoveUp,
    RC_MoveDown,
};

class RepairCrew : public MultiplayerObject, public Updatable
{
    static const float move_speed = 2.0;
    static const float repair_per_second = 0.03;
public:
    sf::Vector2f position;
    sf::Vector2i target_position;
    ERepairCrewAction action;
    float action_delay;
    int32_t ship_id;
    
    RepairCrew();
    
    virtual void onReceiveClientCommand(int32_t clientId, sf::Packet& packet);
    void commandSetTargetPosition(sf::Vector2i position);
    
    virtual void update(float delta);
};
PVector<RepairCrew> getRepairCrewFor(P<PlayerSpaceship> ship);

#endif//REPAIR_CREW_H
