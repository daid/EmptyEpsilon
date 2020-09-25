#ifndef MISSILE_VOLLEY_AI_H
#define MISSILE_VOLLEY_AI_H

#include "ai.h"

class MissileVolleyAI : public ShipAI
{
private:
    enum FlankPosition
    {
        Unknown,
        Left,
        Right
    };

    FlankPosition flank_position;
public:
    MissileVolleyAI(CpuShip* owner);

    /**!
     * Are we allowed to switch to a different AI right now?
     * When true is returned, and the CpuShip wants to change their AI this AI object will be destroyed and a new one will be created.
     */
    virtual bool canSwitchAI();

    virtual void run(float delta);
    virtual void runOrders();
    virtual void runAttack(P<SpaceObject> target);
};


#endif//MISSILE_VOLLEY_AI_H
