#ifndef SHIP_TEMPLATE_BASED_OBJECT_H
#define SHIP_TEMPLATE_BASED_OBJECT_H

#include "engine.h"
#include "spaceObject.h"
//#include "shipTemplate.h"

/**
    An object which is based on a ship template. Contains generic behaviour for:
    * Hull damage
    * Shield damage
    * Rendering
    Used as a base class for stations and ships.
*/
class ShipTemplateBasedObject : public SpaceObject, public Updatable
{
public:
    string template_name;
    //P<ShipTemplate> ship_template;

public:
    ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range=-1);

    virtual void draw3DTransparent() override;
    virtual void update(float delta) override;

    virtual bool canBeTargetedBy(sp::ecs::Entity other) override { return true; }
    virtual bool hasShield() override;

    void setCanBeDestroyed(bool enabled);
    bool getCanBeDestroyed();

    virtual void applyTemplateValues() = 0;

    void setTemplate(string template_name);
    void setShipTemplate(string template_name) { LOG(WARNING) << "Deprecated \"setShipTemplate\" function called."; setTemplate(template_name); }
    void setTypeName(string type_name) { entity.getOrAddComponent<TypeName>().type_name = type_name; }
    string getTypeName() { auto tn = entity.getComponent<TypeName>(); if (tn) return tn->type_name; return ""; }

    float getHull();
    float getHullMax();
    void setHull(float amount);
    void setHullMax(float amount);
    virtual bool getShieldsActive() { return true; }

    ///Shield script binding functions
    float getShieldLevel(int index) { /*TODO*/ return 0.0f; }
    float getShieldMax(int index) { /*TODO*/ return 0.0f; }
    int getShieldCount() { /*TODO*/ return 0; }
    void setShields(const std::vector<float>& amounts);
    void setShieldsMax(const std::vector<float>& amounts);

    int getShieldPercentage(int index) { /*TODO*/ return 0; }

    ///Deprecated old script functions for shields
    float getFrontShield() { /*TODO*/ return 0.0f; }
    float getFrontShieldMax() { /*TODO*/ return 0.0f; }
    void setFrontShield(float amount) { } //TODO
    void setFrontShieldMax(float amount) { } //TODO
    float getRearShield() { /*TODO*/ return 0.0f; }
    float getRearShieldMax() { /*TODO*/ return 0.0f; }
    void setRearShield(float amount) { } //TODO
    void setRearShieldMax(float amount) { } //TODO

    // Radar range
    float getLongRangeRadarRange() { return 30000.0f; } //TODO
    float getShortRangeRadarRange() { return 5000.0f; } //TODO
    void setLongRangeRadarRange(float range) { } //TODO
    void setShortRangeRadarRange(float range) { } //TODO

    void setRadarTrace(string trace);
    void setImpulseSoundFile(string sound);

    bool getSharesEnergyWithDocked();
    void setSharesEnergyWithDocked(bool enabled);
    bool getRepairDocked();
    void setRepairDocked(bool enabled);
    bool getRestocksScanProbes();
    void setRestocksScanProbes(bool enabled);
    bool getRestocksMissilesDocked();
    void setRestocksMissilesDocked(bool enabled);

    void onTakingDamage(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);

    string getShieldDataString();
};

#endif//SHIP_TEMPLATE_BASED_OBJECT_H
