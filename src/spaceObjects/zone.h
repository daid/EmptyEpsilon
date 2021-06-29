#ifndef ZONE_H
#define ZONE_H

#include "spaceObject.h"

class Zone : public SpaceObject
{
public:
    Zone();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range) override;

    virtual bool canHideInNebula()  override { return false; }

    void setColor(int r, int g, int b);
    void setPoints(std::vector<glm::vec2> points);
    void setLabel(string label);
    string getLabel();
    bool isInside(P<SpaceObject> obj);

    //virtual string getExportLine() override { return "Zone():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

private:
    sf::Color color;
    std::vector<glm::vec2> outline;
    std::vector<glm::vec2> triangles;
    string label;
};

#endif//ZONE_H
