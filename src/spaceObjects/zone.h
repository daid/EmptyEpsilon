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
    void setPoints(std::vector<sf::Vector2f> points);
    void setLabel(string label);
    string getLabel();
    bool isInside(P<SpaceObject> obj);

    //virtual string getExportLine() override { return "Zone():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

private:
    sf::Color color;
    std::vector<sf::Vector2f> outline;
    std::vector<sf::Vector2f> triangles;
    string label;
};

#endif//ZONE_H
