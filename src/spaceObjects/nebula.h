#ifndef NEBULA_H
#define NEBULA_H

#include "spaceObject.h"

class NebulaCloud
{
public:
    sf::Vector2f offset;
    int texture;
    float size;
};
class Nebula : public SpaceObject
{
    static PVector<Nebula> nebula_list;
    static const int cloud_count = 32;

    int radar_visual;
    NebulaCloud clouds[cloud_count];
public:
    Nebula();

    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual bool canHideInNebula() { return false; }
    
    static bool blockedByNebula(sf::Vector2f start, sf::Vector2f end);
    static sf::Vector2f getFirstBlockedPosition(sf::Vector2f start, sf::Vector2f end);
};

#endif//NEBULA_H
