#pragma once

#include "ecs/system.h"


class SfxSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
