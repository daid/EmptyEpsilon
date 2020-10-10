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
    color = sf::Color(255, 255, 255, 0);

    registerMemberReplication(&outline);
    registerMemberReplication(&triangles);
    registerMemberReplication(&color);
    registerMemberReplication(&label);
}

void Zone::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    if (!long_range || color.a == 0)
        return;

    sf::VertexArray outline_array(sf::LinesStrip, outline.size() + 1);
    sf::VertexArray triangle_array(sf::Triangles, triangles.size());
    for(unsigned int n=0; n<outline.size() + 1; n++)
    {
        outline_array[n].position = position + sf::rotateVector(outline[n % outline.size()] * scale, -rotation);
        outline_array[n].color = color;
        outline_array[n].color.a = 128;
    }
    for(unsigned int n=0; n<triangles.size(); n++)
    {
        triangle_array[n].position = position + sf::rotateVector(triangles[n] * scale, -rotation);
        triangle_array[n].color = color;
        triangle_array[n].color.a = 64;
    }
    window.draw(triangle_array);
    window.draw(outline_array);

    if (label.length() > 0)
    {
        int font_size = getRadius() * scale / label.length();
        sf::Text text_element(label, *main_font, font_size);

        float x = position.x - text_element.getLocalBounds().width / 2.0 - text_element.getLocalBounds().left;
        float y = position.y - font_size + font_size * 0.35;

        text_element.setPosition(x, y);
        text_element.setColor(sf::Color(color.r, color.g, color.b, 128));
        window.draw(text_element);
    }
}

void Zone::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    if (long_range && color.a == 0)
    {
        color.a = 255;
        drawOnRadar(window, position, scale, rotation, long_range);
        color.a = 0;
    }
}

void Zone::setColor(int r, int g, int b)
{
    color = sf::Color(r, g, b);
}

void Zone::setPoints(std::vector<sf::Vector2f> points)
{
    triangles.clear();

    sf::Vector2f position = centerOfMass(points);
    float radius = 1;
    for(auto& p : points)
    {
        p -= position;
        radius = std::max(radius, sf::length(p));
    }

    outline = points;
    Triangulate<float>::process(points, triangles);

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
