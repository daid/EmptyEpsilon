#ifndef FIGHTER_AI_H
#define FIGHTER_AI_H

#include "ai.h"

class FighterAI : public ShipAI
{
    enum 
    {
        dive,
        evade,
        recharge
    } attack_state;
    float timeout;
    float evade_direction;
public:
    FighterAI(CpuShip* owner);

    virtual void run(float delta);
    virtual void runAttack(P<SpaceObject> target);
};


#endif//FIGHTER_AI_H
