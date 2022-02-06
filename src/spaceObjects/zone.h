#ifndef ZONE_H
#define ZONE_H

#include "spaceObject.h"

class Zone : public SpaceObject
{
public:
    Zone();

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual bool canHideInNebula()  override { return false; }
    virtual ERadarLayer getRadarLayer() const override { return ERadarLayer::BackgroundZone; }

    void setColor(int r, int g, int b);
    void setPoints(const std::vector<glm::vec2>& points);
    void setLabel(string label);
    string getLabel();
    bool isInside(P<SpaceObject> obj);

    //virtual string getExportLine() override { return "Zone():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

private:
    glm::u8vec4 color{255,255,255,255};
    std::vector<glm::vec2> outline;
    std::vector<uint16_t> triangles;
    string label;
};

#endif//ZONE_H
