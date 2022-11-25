#pragma once

#include "ecs/system.h"


class WarpSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
