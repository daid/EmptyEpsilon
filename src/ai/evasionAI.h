#ifndef EVASION_AI_H
#define EVASION_AI_H

#include "ai.h"

class EvasionAI : public ShipAI
{
private:
    float evasion_calculation_delay;
    bool is_evading;
    glm::vec2 evasion_location{0, 0};
public:
    EvasionAI(sp::ecs::Entity owner);

    virtual bool canSwitchAI() override;
    virtual void run(float delta) override;
    virtual void runOrders() override;

    virtual bool evadeIfNecessary();
    float evasionDangerScore(sp::ecs::Entity ship, float scan_radius);
};


#endif//EVASION_AI_H
