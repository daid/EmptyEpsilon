#pragma once

#include "ecs/system.h"
#include "systems/radar.h"
#include "components/gravity.h"


class GravitySystem : public sp::ecs::System, public RenderRadarInterface<Gravity, 12, RadarRenderSystem::FlagGM>
{
public:
    void update(float delta) override;
    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Gravity& component) override;
};
