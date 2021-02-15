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
    string radar_trace;
    string impulse_sound_file;
    P<ShipTemplate> ship_template;

    int shield_count;
    float shield_level[max_shield_count];
    float shield_max[max_shield_count];
    float hull_strength, hull_max;
    float shield_hit_effect[max_shield_count];
    bool can_be_destroyed;

    bool shares_energy_with_docked;       //[config]
    bool repair_docked;                   //[config]
    bool restocks_scan_probes;
    bool restocks_missiles_docked;        //only restocks cpuships; playerships should use comms

    ScriptSimpleCallback on_destruction;
    ScriptSimpleCallback on_taking_damage;
public:
    ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range=-1);

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent() override;
#endif
    virtual void drawShieldsOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, float sprite_scale, bool show_levels);
    virtual void update(float delta) override;

    virtual std::unordered_map<string, string> getGMInfo() override;
    virtual bool canRestockMissiles() override { return restocks_missiles_docked; }
    virtual bool canBeTargetedBy(P<SpaceObject> other) override { return true; }
    virtual bool hasShield() override;
    virtual string getCallSign() override { return callsign; }
    virtual void takeDamage(float damage_amount, DamageInfo info) override;
    virtual void takeHullDamage(float damage_amount, DamageInfo& info);
    virtual void destroyedByDamage(DamageInfo& info) = 0;
    virtual float getShieldDamageFactor(DamageInfo& info, int shield_index);

    void setCanBeDestroyed(bool enabled) { can_be_destroyed = enabled; }
    bool getCanBeDestroyed(){ return can_be_destroyed; }

    virtual void applyTemplateValues() = 0;
    virtual float getShieldRechargeRate(int shield_index);

    void setTemplate(string template_name);
    void setShipTemplate(string template_name) { LOG(WARNING) << "Deprecated \"setShipTemplate\" function called."; setTemplate(template_name); }
    void setTypeName(string type_name) { this->type_name = type_name; }
    string getTypeName() { return type_name; }

    float getHull() { return hull_strength; }
    float getHullMax() { return hull_max; }
    void setHull(float amount) { if (amount < 0) return; hull_strength = amount; }
    void setHullMax(float amount) { if (amount < 0) return; hull_max = amount; hull_strength = std::max(hull_strength, hull_max); }
    virtual bool getShieldsActive() { return true; }

    ///Shield script binding functions
    float getShieldLevel(int index) { if (index < 0 || index >= shield_count) return 0; return shield_level[index]; }
    float getShieldMax(int index) { if (index < 0 || index >= shield_count) return 0; return shield_max[index]; }
    int getShieldCount() { return shield_count; }
    void setShields(std::vector<float> amounts);
    void setShieldsMax(std::vector<float> amounts);

    int getShieldPercentage(int index) { if (index < 0 || index >= shield_count || shield_max[index] <= 0.0) return 0; return int(100 * shield_level[index] / shield_max[index]); }
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

    void setRadarTrace(string trace) { radar_trace = trace; }
    void setImpulseSoundFile(string sound) { impulse_sound_file = sound; }

    bool getSharesEnergyWithDocked() { return shares_energy_with_docked; }
    void setSharesEnergyWithDocked(bool enabled) { shares_energy_with_docked = enabled; }
    bool getRepairDocked() { return repair_docked; }
    void setRepairDocked(bool enabled) { repair_docked = enabled; }
    bool getRestocksScanProbes() { return restocks_scan_probes; }
    void setRestocksScanProbes(bool enabled) { restocks_scan_probes = enabled; }
    bool getRestocksMissilesDocked() { return restocks_missiles_docked; }
    void setRestocksMissilesDocked(bool enabled) { restocks_missiles_docked = enabled; }

    void onTakingDamage(ScriptSimpleCallback callback);
    void onDestruction(ScriptSimpleCallback callback);

    string getShieldDataString();
};

#endif//SHIP_TEMPLATE_BASED_OBJECT_H
