#include "systems/zone.h"
#include "main.h"


void ZoneSystem::update(float delta)
{
}

void ZoneSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Zone& zone)
{
    if (zone.color.a == 0 || zone.outline.empty())
        return;
    std::vector<glm::vec2> outline_points;
    for(auto p : zone.outline)
        outline_points.push_back(screen_position + rotateVec2(p * scale, -rotation));
    renderer.drawTriangles(outline_points, zone.triangles, glm::u8vec4(zone.color.r, zone.color.g, zone.color.b, 64));
    
    outline_points.push_back(screen_position + rotateVec2(zone.outline[0] * scale, -rotation));
    renderer.drawLine(outline_points, glm::u8vec4(zone.color.r, zone.color.g, zone.color.b, 128));

    if (zone.label.length() > 0)
    {
        auto label_pos = screen_position + zone.label_offset * scale;
        float font_size = zone.radius * scale / zone.label.length();
        renderer.drawText(sp::Rect(label_pos.x, label_pos.y, 0, 0), zone.label, sp::Alignment::Center, font_size, main_font, glm::u8vec4(zone.color.r, zone.color.g, zone.color.b, 128));
    }
}
