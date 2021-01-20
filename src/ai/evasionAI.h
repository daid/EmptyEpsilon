#ifndef EVASION_AI_H
#define EVASION_AI_H

#include "ai.h"

class EvasionAI : public ShipAI
{
private:
    float evasion_calculation_delay;
    bool is_evading;
    sf::Vector2f evasion_location;
public:
    EvasionAI(CpuShip* owner);

    virtual bool canSwitchAI();
    virtual void run(float delta);
    virtual void runOrders();

    virtual bool evadeIfNecessary();
    float evasionDangerScore(P<SpaceShip> ship, float scan_radius);
};


#endif//EVASION_AI_H
