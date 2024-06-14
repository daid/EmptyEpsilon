#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"
#include "radar.h"
#include "components/zone.h"


class ZoneSystem : public sp::ecs::System, public RenderRadarInterface<Zone, 20, RadarRenderSystem::FlagLongRange>
{
public:
    void update(float delta) override;
    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Zone& component) override;
};
