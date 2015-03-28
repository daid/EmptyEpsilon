#ifndef SUPPLY_DROP_H
#define SUPPLY_DROP_H

#include "spaceObject.h"

class WarpJammer : public SpaceObject
{
    static PVector<WarpJammer> jammer_list;

    float range;
    float hull;
public:
    WarpJammer();

    void setRange(float range) { this->range = range; }

    virtual void draw3D();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual bool canBeTargeted() { return true; }
    virtual void takeDamage(float damage_amount, DamageInfo& info);

    static bool isWarpJammed(sf::Vector2f position);
    static sf::Vector2f getFirstNoneJammedPosition(sf::Vector2f start, sf::Vector2f end);
};

#endif//ASTEROID_H

