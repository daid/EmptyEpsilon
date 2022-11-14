#pragma once

#include "ecs/system.h"


class BeamWeaponSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
