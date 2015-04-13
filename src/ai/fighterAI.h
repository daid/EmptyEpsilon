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
    float aggression;
public:
    FighterAI(CpuShip* owner);

    /**!
     * Are we allowed to switch to a different AI right now?
     * When true is returned, and the CpuShip wants to change their AI this AI object will be destroyed and a new one will be created.
     */
    virtual bool canSwitchAI();

    virtual void run(float delta);
    virtual void runOrders();
    virtual void runAttack(P<SpaceObject> target);
};


#endif//FIGHTER_AI_H
