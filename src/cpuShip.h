#ifndef CPU_SHIP_H
#define CPU_SHIP_H

#include "spaceShip.h"

enum EAIState
{
    AI_Engage,
    AI_Disengage,
    AI_Flee,
};

class CpuShip : public SpaceShip
{
    EAIState state;
public:
    CpuShip();
    
    virtual void update(float delta);
};

#endif//CPU_SHIP_H
