#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "engine.h"
#include "spaceObject.h"
#include "shipTemplate.h"

class SpaceStation : public SpaceObject, public Updatable
{
    static const float shieldRechargeRate = 0.2;
    float shieldHitEffect;

    string templateName;
    P<ShipTemplate> shipTemplate;   //Space stations use a shipTemplate to get hull/shield and graphical information.
public:
    float shields, shields_max;
    float hull_strength, hull_max;

    SpaceStation();
    
    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void update(float delta);
    
    virtual string getCallSign() { return "DS" + string(getMultiplayerId()); }
    virtual bool canBeTargeted() { return true; }
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual bool hasShield() { return shields > (shields_max / 50.0); }
    virtual void takeDamage(float damageAmount, DamageInfo& info);
    
    void setTemplate(string templateName);
};

#endif//SPACE_SHIP_H
