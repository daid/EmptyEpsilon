#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "engine.h"
#include "spaceObject.h"
#include "shipTemplate.h"

class SpaceStation : public SpaceObject, public Updatable
{
    static constexpr float shieldRechargeRate = 0.2;
    float shieldHitEffect;
    string callsign;
public:
    string template_name;
    string radar_trace;
    P<ShipTemplate> ship_template;   //Space stations use a shipTemplate to get hull/shield and graphical information.

    float shields, shields_max;
    float hull_strength, hull_max;

    SpaceStation();

    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void update(float delta);

    virtual std::unordered_map<string, string> getGMInfo();
    virtual string getCallSign() { return callsign; }
    virtual bool canBeTargeted() { return true; }
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual bool hasShield() { return shields > (shields_max / 50.0); }
    virtual void takeDamage(float damage_amount, DamageInfo info);

    void setTemplate(string template_name);
    void setCallSign(string new_callsign) { callsign = new_callsign; }

    float getHull() { return hull_strength; }
    float getHullMax() { return hull_max; }
    void setHull(float amount) { if (amount < 0) return; hull_strength = amount; }
    void setHullMax(float amount) { if (amount < 0) return; hull_max = amount; hull_strength = std::max(hull_strength, hull_max); }
    float getShield() { return shields; }
    float getShieldMax() { return shields_max; }
    void setShield(float amount) { if (amount < 0) return; shields = amount; }
    void setShieldMax(float amount) { if (amount < 0) return; shields_max = amount; shields = std::max(shields, shields_max); }

    virtual string getExportLine();
};

#endif//SPACE_SHIP_H
