#pragma once

#include <glm/vec2.hpp>
#include <ecs/entity.h>
#include "components/radar.h"
#include "systems/radar.h"


class PlayerRadarRender : public sp::ecs::System, public RenderRadarInterface<LongRangeRadar, 11, RadarRenderSystem::FlagGM>
{
public:
    void update(float delta) override {}

    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, LongRangeRadar& component) override;
};