#include "main.h"
#include "zone.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "explosionEffect.h"
#include "pathPlanner.h"

#include "math/triangulate.h"
#include "math/centerOfMass.h"

#include "scriptInterface.h"

/// A zone area
REGISTER_SCRIPT_SUBCLASS(Zone, SpaceObject)
{
    /// Set corners of n-gon to x_1, y_1, x_2, y_2, ..., x_n, y_n.
    /// Recall that x goes right and y goes down.
    /// Example: zone = Zone():setPoints(2000, 0, 0, 3000, -2000, 0)
    REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setPoints);
    /// Example: zone:setColor(255, 140, 0)
    REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setColor);
    REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setLabel);
    REGISTER_SCRIPT_CLASS_FUNCTION(Zone, getLabel);
    REGISTER_SCRIPT_CLASS_FUNCTION(Zone, isInside);
}

REGISTER_MULTIPLAYER_CLASS(Zone, "Zone");
Zone::Zone()
: SpaceObject(1, "Zone")
{
    has_weight = false;
    color = glm::u8vec4(255, 255, 255, 0);

    registerMemberReplication(&outline);
    registerMemberReplication(&triangles);
    registerMemberReplication(&color);
    registerMemberReplication(&label);
}

void Zone::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (!long_range || color.a == 0 || !outline.size())
        return;
    std::vector<glm::vec2> triangle_points;
    for(auto p : triangles)
        triangle_points.push_back(position + rotateVec2(p, -rotation));
    renderer.drawTriangleStrip(triangle_points, glm::u8vec4(color.r, color.g, color.b, 64));
    std::vector<glm::vec2> outline_points;
    for(auto p : outline)
        outline_points.push_back(position + rotateVec2(p, -rotation));
    outline_points.push_back(position + rotateVec2(outline[0], -rotation));
    renderer.drawLine(outline_points, glm::u8vec4(color.r, color.g, color.b, 128));

    if (label.length() > 0)
    {
        float font_size = getRadius() * scale / label.length();
        renderer.drawText(sp::Rect(position.x, position.y, 0, 0), label, sp::Alignment::Center, font_size, main_font, glm::u8vec4(color.r, color.g, color.b, 128));
    }
}

void Zone::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (long_range && color.a == 0)
    {
        color.a = 255;
        drawOnRadar(renderer, position, scale, rotation, long_range);
        color.a = 0;
    }
}

void Zone::setColor(int r, int g, int b)
{
    color = glm::u8vec4(r, g, b, 255);
}

void Zone::setPoints(std::vector<glm::vec2> points)
{
    triangles.clear();

    glm::vec2 position = centerOfMass(points);
    float radius = 1;
    for(auto& p : points)
    {
        p -= position;
        radius = std::max(radius, glm::length(p));
    }

    outline = points;
    Triangulate::process(points, triangles);

    setPosition(position);
    setRadius(radius);
    setCollisionRadius(1);
}

void Zone::setLabel(string label)
{
    this->label = label;
}

string Zone::getLabel()
{
    return this->label;
}

bool Zone::isInside(P<SpaceObject> obj)
{
    if (!obj)
        return false;
    return insidePolygon(outline, obj->getPosition() - getPosition());
}
