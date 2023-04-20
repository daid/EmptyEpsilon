#pragma once

#include "ecs/system.h"
#include "systems/rendering.h"

class BeamWeaponSystem : public sp::ecs::System, public Render3DInterface
{
public:
    BeamWeaponSystem();

    void update(float delta) override;

    void render3D(sp::ecs::Entity e) override;
};
