#include "systems/gm.h"
#include "components/player.h"
#include "ai/ai.h"


void GMRadarRender::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, LongRangeRadar& component)
{
    if (!e.hasComponent<PlayerControl>()) return;
    renderer.drawCircleOutline(screen_position, component.short_range * scale, 3.0, glm::u8vec4(255, 255, 255, 64));
    renderer.drawCircleOutline(screen_position, component.long_range * scale, 3.0, glm::u8vec4(255, 255, 255, 64));
}

void GMRadarRender::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, AIController& component)
{
    if (component.ai)
        component.ai->drawOnGMRadar(renderer, screen_position, scale);
}

void GMRadarRender::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, AllowRadarLink& component)
{
    if (!component.owner || !component.owner.hasComponent<PlayerControl>())
        return;

    float range = 5000;
    auto radar = e.getComponent<LongRangeRadar>();
    if (radar)
        range = radar->short_range;

    renderer.drawCircleOutline(screen_position, range * scale, 3.0, glm::u8vec4(255, 255, 255, 64));
}
