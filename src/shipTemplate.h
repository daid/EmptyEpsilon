#ifndef SHIP_TEMPLATE_H
#define SHIP_TEMPLATE_H

#include <map>
#include "engine.h"

class ShipTemplate : public PObject
{
    static std::map<string, P<ShipTemplate> > templateMap;

    string name;
public:
    float scale;
    string model, colorTexture, specularTexture, illuminationTexture;
    sf::Vector3f beamPosition[16];

    ShipTemplate() { scale = 1.0; }
    
    void setName(string name);
    void setScale(float scale);
    void setMesh(string model, string colorTexture, string specularTexture, string illuminationTexture);
    void setBeamPosition(int index, sf::Vector3f position);
public:
    static P<ShipTemplate> getTemplate(string name);
};

#endif//SHIP_TEMPLATE_H
