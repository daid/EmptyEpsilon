#pragma once

#include "ecs/system.h"
#include "systems/radar.h"
#include "components/shields.h"


class ShieldSystem : public sp::ecs::System, public RenderRadarInterface<Shields, 20, RadarRenderSystem::FlagShortRange>
{
public:
    void update(float delta) override;

    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Shields& component) override;
};
