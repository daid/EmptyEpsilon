#pragma once

#include <glm/vec2.hpp>
#include <ecs/entity.h>
#include "components/radarblock.h"
#include "systems/radar.h"


class RadarBlockSystem : public sp::ecs::System, public RenderRadarInterface<RadarBlock, 11, RadarRenderSystem::FlagGM>
{
public:
    void update(float delta) override {}

    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, RadarBlock& component) override;
    static bool isRadarBlockedFrom(glm::vec2 source, sp::ecs::Entity entity, float short_range);
};