#pragma once

#include "ecs/system.h"
#include "systems/radar.h"
#include "systems/rendering.h"
#include "components/shields.h"


class ShieldSystem : public sp::ecs::System, public RenderRadarInterface<Shields, 20, RadarRenderSystem::FlagShortRange>, public Render3DInterface
{
public:
    ShieldSystem();
    void update(float delta) override;
    void render3D(sp::ecs::Entity e) override;

    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Shields& component) override;
};
