#ifndef BLACK_HOLE_H
#define BLACK_HOLE_H

#include "spaceObject.h"

class BlackHole : public SpaceObject, public Updatable
{
    float update_delta;

public:
    BlackHole();

    virtual void update(float delta) override;

    virtual void draw3DTransparent() override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual ERadarLayer getRadarLayer() const override { return ERadarLayer::BackgroundObjects; }

    virtual string getExportLine() override { return "BlackHole():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }
};

#endif//BLACK_HOLE_H
