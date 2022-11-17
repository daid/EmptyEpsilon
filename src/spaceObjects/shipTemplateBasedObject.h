#ifndef SHIP_TEMPLATE_BASED_OBJECT_H
#define SHIP_TEMPLATE_BASED_OBJECT_H

#include "engine.h"
#include "spaceObject.h"
#include "shipTemplate.h"

/**
    An object which is based on a ship template. Contains generic behaviour for:
    * Hull damage
    * Shield damage
    * Rendering
    Used as a base class for stations and ships.
*/
class ShipTemplateBasedObject : public SpaceObject, public Updatable
{
private:
    float long_range_radar_range;
    float short_range_radar_range;
public:
    string template_name;
    string type_name;
    P<ShipTemplate> ship_template;

    int shield_count;
    float shield_level[max_shield_count];
    float shield_max[max_shield_count];
    float shield_hit_effect[max_shield_count];

public:
    ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range=-1);

    virtual void draw3DTransparent() override;
    virtual void drawShieldsOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, float sprite_scale, bool show_levels);
    virtual void update(float delta) override;

    virtual std::unordered_map<string, string> getGMInfo() override;
    virtual bool canBeTargetedBy(P<SpaceObject> other) override { return true; }
    virtual bool hasShield() override;
    virtual string getCallSign() override { return callsign; }
    virtual void takeDamage(float damage_amount, DamageInfo info) override;
    virtual void takeHullDamage(float damage_amount, DamageInfo& info);
    virtual void destroyedByDamage(DamageInfo& info) = 0;
    virtual float getShieldDamageFactor(DamageInfo& info, int shield_index);

    void setCanBeDestroyed(bool enabled);
    bool getCanBeDestroyed();

    virtual void applyTemplateValues() = 0;
    virtual float getShieldRechargeRate(int shield_index);

    void setTemplate(string template_name);
    void setShipTemplate(string template_name) { LOG(WARNING) << "Deprecated \"setShipTemplate\" function called."; setTemplate(template_name); }
    void setTypeName(string type_name) { this->type_name = type_name; }
    string getTypeName() { return type_name; }

    float getHull();
    float getHullMax();
    void setHull(float amount);
    void setHullMax(float amount);
    virtual bool getShieldsActive() { return true; }

    ///Shield script binding functions
    float getShieldLevel(int index) { if (index < 0 || index >= shield_count) return 0; return shield_level[index]; }
    float getShieldMax(int index) { if (index < 0 || index >= shield_count) return 0; return shield_max[index]; }
    int getShieldCount() { return shield_count; }
    void setShields(const std::vector<float>& amounts);
    void setShieldsMax(const std::vector<float>& amounts);

    int getShieldPercentage(int index) { if (index < 0 || index >= shield_count || shield_max[index] <= 0.0f) return 0; return int(100 * shield_level[index] / shield_max[index]); }
    ESystem getShieldSystemForShieldIndex(int index);

    ///Deprecated old script functions for shields
    float getFrontShield() { return shield_level[0]; }
    float getFrontShieldMax() { return shield_max[0]; }
    void setFrontShield(float amount) { if (amount < 0) return; shield_level[0] = amount; }
    void setFrontShieldMax(float amount) { if (amount < 0) return; shield_level[0] = amount; shield_level[0] = std::min(shield_level[0], shield_max[0]); }
    float getRearShield() { return shield_level[1]; }
    float getRearShieldMax() { return shield_max[1]; }
    void setRearShield(float amount) { if (amount < 0) return; shield_level[1] = amount; }
    void setRearShieldMax(float amount) { if (amount < 0) return; shield_max[1] = amount; shield_level[1] = std::min(shield_level[1], shield_max[1]); }

    // Radar range
    float getLongRangeRadarRange() { return long_range_radar_range; }
    float getShortRangeRadarRange() { return short_range_radar_range; }
    void setLongRangeRadarRange(float range) { range = std::max(range, 100.0f); long_range_radar_range = range; short_range_radar_range = std::min(short_range_radar_range, range); }
    void setShortRangeRadarRange(float range) { range = std::max(range, 100.0f); short_range_radar_range = range; long_range_radar_range = std::max(long_range_radar_range, range); }

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
