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
    
    virtual RawRadarSignatureInfo getRadarSignatureInfo() override { return RawRadarSignatureInfo(0.05, 0.5, 0.0); }

    void setRange(float range) { this->range = range; }

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;

    virtual bool canBeTargetedBy(P<SpaceObject> other)  override { return true; }
    virtual void takeDamage(float damage_amount, DamageInfo info) override;

    static bool isWarpJammed(sf::Vector2f position);
    static sf::Vector2f getFirstNoneJammedPosition(sf::Vector2f start, sf::Vector2f end);
    
    virtual string getExportLine() { return "WarpJammer():setFaction(\"" + getFaction() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }
};

#endif//ASTEROID_H

