#ifndef NEBULA_H
#define NEBULA_H

#include "spaceObject.h"

class NebulaCloud
{
public:
    glm::vec2 offset;
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

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent();
#endif
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range);
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range);
    virtual bool canHideInNebula() { return false; }

    static bool inNebula(glm::vec2 position);
    static bool blockedByNebula(glm::vec2 start, glm::vec2 end, float radar_short_range);
    static glm::vec2 getFirstBlockedPosition(glm::vec2 start, glm::vec2 end);
    static PVector<Nebula> getNebulas();

    virtual string getExportLine() { return "Nebula():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

protected:
    glm::mat4 getModelMatrix() const override;
};

#endif//NEBULA_H
