#include "systems/player.h"
#include "components/player.h"


void PlayerRadarRender::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, LongRangeRadar& component)
{
    if (!e.hasComponent<PlayerControl>()) return;
    renderer.drawCircleOutline(screen_position, component.short_range * scale, 3.0, glm::u8vec4(255, 255, 255, 64));
    renderer.drawCircleOutline(screen_position, component.long_range * scale, 3.0, glm::u8vec4(255, 255, 255, 64));
}
