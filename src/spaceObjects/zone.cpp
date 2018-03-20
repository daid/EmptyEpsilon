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
    REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setPoints);
}

REGISTER_MULTIPLAYER_CLASS(Zone, "Zone");
Zone::Zone()
: SpaceObject(1, "Zone")
{
    color = sf::Color(255, 255, 255, 0);
    
    registerMemberReplication(&outline);
    registerMemberReplication(&triangles);
    registerMemberReplication(&color);
    registerMemberReplication(&label);
}

void Zone::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (!long_range || color.a == 0)
        return;
    
    sf::VertexArray outline_array(sf::LinesStrip, outline.size() + 1);
    sf::VertexArray triangle_array(sf::Triangles, triangles.size());
    for(unsigned int n=0; n<outline.size() + 1; n++)
    {
        outline_array[n].position = position + outline[n % outline.size()] * scale;
        outline_array[n].color = color;
        outline_array[n].color.a = 128;
    }
    for(unsigned int n=0; n<triangles.size(); n++)
    {
        triangle_array[n].position = position + triangles[n] * scale;
        triangle_array[n].color = color;
        triangle_array[n].color.a = 64;
    }
    window.draw(triangle_array);
    window.draw(outline_array);
}

void Zone::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (long_range && color.a == 0)
    {
        color.a = 255;
        drawOnRadar(window, position, scale, long_range);
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
