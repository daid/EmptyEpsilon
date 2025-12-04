#pragma once

#include "ecs/system.h"
#include "systems/radar.h"
#include "systems/rendering.h"
#include "components/collision.h"


class DebugRenderSystem : public sp::ecs::System, public RenderRadarInterface<sp::Physics, 100, RadarRenderSystem::FlagShortRange>, public Render3DInterface<sp::Physics, true>
{
public:
    DebugRenderSystem();
    bool show_colliders;

    void update(float delta) override;
    void render3D(sp::ecs::Entity e, sp::Transform& transform, sp::Physics& shields) override;

    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, sp::Physics& component) override;
};
