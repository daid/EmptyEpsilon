#pragma once

#include "systems/rendering.h"


class PlanetRenderSystem : public sp::ecs::System, public Render3DInterface<PlanetRender, false>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, PlanetRender& pr) override;
};
class PlanetTransparentRenderSystem : public sp::ecs::System, public Render3DInterface<PlanetRender, true>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, PlanetRender& pr) override;
};
