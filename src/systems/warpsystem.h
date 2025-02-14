#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"
#include "radar.h"
#include "components/warpdrive.h"
#include <glm/vec2.hpp>


class WarpSystem : public sp::ecs::System, public RenderRadarInterface<WarpJammer, 20, RadarRenderSystem::FlagLongRange>
{
public:
    void update(float delta) override;
    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, WarpJammer& component) override;

    static bool isWarpJammed(sp::ecs::Entity);
    static glm::vec2 getFirstNoneJammedPosition(glm::vec2 start, glm::vec2 end);
};
