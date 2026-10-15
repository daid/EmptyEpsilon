#pragma once

#include "ecs/system.h"

class LifeTimeSystem: public sp::ecs::System
{
public:
    void update(float delta) override;    
};
