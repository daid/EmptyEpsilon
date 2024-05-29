#include "systems/radarblock.h"
#include "components/radarblock.h"
#include "components/collision.h"
#include "ecs/query.h"
#include <glm/gtx/norm.hpp>


void RadarBlockSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, RadarBlock& component)
{
    renderer.drawCircleOutline(screen_position, component.range * scale, 2.0, glm::u8vec4(255, 255, 255, 64));
}

bool RadarBlockSystem::isRadarBlockedFrom(glm::vec2 source, sp::ecs::Entity entity, float short_range)
{
    if (entity.hasComponent<NeverRadarBlocked>()) return false;
    auto et = entity.getComponent<sp::Transform>();
    if (!et) return false;

    auto startEndDiff = et->getPosition() - source;
    float startEndLength = glm::length(startEndDiff);
    if (startEndLength < short_range)
        return false;

    for(auto [entity, block, transform] : sp::ecs::Query<RadarBlock, sp::Transform>())
    {
        if (block.behind) {
            //Calculate point q, which is a point on the line start-end that is closest to n->getPosition
            float f = glm::dot(startEndDiff, transform.getPosition() - source) / startEndLength;
            if (f < 0.0f)
                f = 0.0f;
            if (f > startEndLength)
                f = startEndLength;
            auto q = source + startEndDiff / startEndLength * f;
            if (glm::length2(q - transform.getPosition()) < block.range*block.range)
                return true;
        } else {
            if (glm::length2(source - transform.getPosition()) < block.range*block.range)
                return true;
        }
    }
    return false;
}
