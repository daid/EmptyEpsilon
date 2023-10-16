#pragma once

#include "systems/rendering.h"


class PlanetRenderSystem : public sp::ecs::System, public Render3DInterface
{
public:
    PlanetRenderSystem();
    void update(float delta) override;
    void render3D(sp::ecs::Entity e) override;
};
class PlanetTransparentRenderSystem : public sp::ecs::System, public Render3DInterface
{
public:
    PlanetTransparentRenderSystem();
    void update(float delta) override;
    void render3D(sp::ecs::Entity e) override;
};
