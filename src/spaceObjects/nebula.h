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
    static const int cloud_count = 32;

public:
    float radius = 5000.0;

    Nebula();

    virtual void draw3DTransparent() override;
    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual ERadarLayer getRadarLayer() const override { return ERadarLayer::BackgroundObjects; }

    virtual string getExportLine() override { return "Nebula():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

protected:
    glm::mat4 getModelMatrix() const override;
};

#endif//NEBULA_H
