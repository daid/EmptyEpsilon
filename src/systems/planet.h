#pragma once

#include "systems/rendering.h"
#include "systems/radar.h"


class PlanetRenderSystem : public sp::ecs::System, public Render3DInterface<PlanetRender, false>, public RenderRadarInterface<PlanetRender, 11, RadarRenderSystem::FlagNone>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, PlanetRender& pr) override;
    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, PlanetRender& component) override;
};
class PlanetTransparentRenderSystem : public sp::ecs::System, public Render3DInterface<PlanetRender, true>
{
public:
    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, PlanetRender& pr) override;
};
