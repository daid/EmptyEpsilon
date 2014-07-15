#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "engine.h"
#include "spaceObject.h"

class SpaceStation : public SpaceObject, public Updatable
{
    static const float maxShields = 400.0;
    static const float shieldRechargeRate = 0.2;
    static const float maxHullStrength = 200;
    float shieldHitEffect;
public:
    float shields;
    float hullStrength;

    SpaceStation();
    
    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void update(float delta);
    
    virtual string getCallSign() { return "DS" + string(getMultiplayerId()); }
    virtual bool canBeTargeted() { return true; }
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual bool hasShield() { return shields > (maxShields / 50.0); }
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type);
};

#endif//SPACE_SHIP_H
