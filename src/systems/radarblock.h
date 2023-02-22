#pragma once

#include <glm/vec2.hpp>
#include <ecs/entity.h>


class RadarBlockSystem
{
public:
    static bool isRadarBlockedFrom(glm::vec2 source, sp::ecs::Entity entity, float short_range);
};