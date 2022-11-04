#pragma once

#include "ecs/system.h"

class DockingSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
