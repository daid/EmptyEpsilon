#include "shipTemplateBasedObject.h"

#include "scriptInterface.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/hull.h"
#include "components/shields.h"

#include "tween.h"
#include "i18n.h"


REGISTER_SCRIPT_SUBCLASS_NO_CREATE(ShipTemplateBasedObject, SpaceObject)
{
    /// Set the template to be used for this ship or station. Templates define hull/shields/looks etc.
    /// Examples:
    /// CpuShip():setTemplate("Phobos T3")
    /// PlayerSpaceship():setTemplate("Phobos M3P")
    /// SpaceStation():setTemplate("Large Station")
    /// WARNING: Using a string that is not a valid template name lets the game crash! This is case-sensitive.
    /// See `scripts/shipTemplates.lua` for the existing templates.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTemplate);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShipTemplate);
    /// Set the class name of this object. Normally the class name is copied from the template name (Ex "Cruiser") but you can override it with this function.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTypeName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getTypeName);
    /// Get the current amount of hull
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHull);
    /// Get the maximum hull value
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHullMax);
    /// Set the current hull value, note that setting this to 0 does not destroy the station.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHull);
    /// Set the maximum amount of hull for this station. Stations never repair hull damage, so this only effects the percentage displays
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHullMax);
    /// Set whether the object can be destroyed.
    /// Requires a Boolean value.
    /// Example: ship:setCanBeDestroyed(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setCanBeDestroyed);
    /// Get whether the object can be destroyed.
    /// Returns a Boolean value.
    /// Example: ship:getCanBeDestroyed()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getCanBeDestroyed);
    /// Get the specified shield's current level.
    /// Requires an integer index value.
    /// Returns a float value.
    /// Example to get shield level on front shields of a ship with two shields:
    ///     ship:getShieldLevel(0)
    /// Rear shields: ship:getShieldLevel(1)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldLevel);
    /// Get the number of shields on this object.
    /// For example, a ship with 1 shield count has a single shield covering
    /// all angles, a ship with 2 covers front and back, etc.
    /// Returns an integer count.
    /// Example: ship:getShieldCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldCount);
    /// Get the maxium shield level.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldMax);
    /// Set the current amount of shields.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShields);
    /// Set the maximum shield level, amount of parameters defines the amount of shields. (Up to a maximum of 8 shields). Note that this does low the current shield level when the max becomes lower, but it does not increase the shield level.
    /// A seperate call to setShield is needed for that.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShieldsMax);
    /// Set the icon to be used for this object on the radar.
    /// For example, station:setRadarTrace("arrow.png") will show an arrow instead of a dot for this station.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRadarTrace);
    /// Set the sound file to be used for this object's impulse engines.
    /// Requires a string for a filename relative to the resources path.
    /// Example: setImpulseSoundFile("engine.wav")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setImpulseSoundFile);
    /// Are the shields online or not. Currently always returns true except for player ships, as only players can turn off shields.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldsActive);

    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getSharesEnergyWithDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setSharesEnergyWithDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRepairDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRepairDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksScanProbes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksScanProbes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksMissilesDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksMissilesDocked);

    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getLongRangeRadarRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShortRangeRadarRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setLongRangeRadarRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShortRangeRadarRange);

    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShieldMax);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShieldMax);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShieldMax);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShieldMax);
    /// Set a function that will be called if the object is taking damage.
    /// First argument given to the function will be the object taking damage, the second the instigator SpaceObject (or nil).
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onTakingDamage);
    /// Set a function that will be called if the object is destroyed by taking damage.
    /// First argument given to the function will be the object taking damage, the second the instigator SpaceObject that gave the final blow (or nil).
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onDestruction);
}

ShipTemplateBasedObject::ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: SpaceObject(collision_range, multiplayer_name, multiplayer_significant_range)
{
    entity.getOrAddComponent<sp::Physics>().setCircle(sp::Physics::Type::Dynamic, collision_range);

    long_range_radar_range = 30000.0f;
    short_range_radar_range = 5000.0f;

    registerMemberReplication(&template_name);
    registerMemberReplication(&type_name);
    registerMemberReplication(&long_range_radar_range, 0.5);
    registerMemberReplication(&short_range_radar_range, 0.5);

    callsign = "[" + string(getMultiplayerId()) + "]";
}

void ShipTemplateBasedObject::draw3DTransparent()
{
    auto shields = entity.getComponent<Shields>();
    if (!shields)
        return;

    float angle = 0.0;
    float arc = 360.0f / shields->count;
    const auto model_matrix = getModelMatrix();
    for(int n = 0; n<shields->count; n++)
    {
        if (shields->entry[n].hit_effect > 0)
        {
            if (shields->count > 1)
            {
                model_info.renderShield(model_matrix, (shields->entry[n].level / shields->entry[n].max) * shields->entry[n].hit_effect, angle);
            }else{
                model_info.renderShield(model_matrix, (shields->entry[n].level / shields->entry[n].max) * shields->entry[n].hit_effect);
            }
        }
        angle += arc;
    }
}

void ShipTemplateBasedObject::update(float delta)
{
    // All ShipTemplateBasedObjects should have a valid template.
    // If this object lacks a template, or has an inconsistent template...
    if (!ship_template || ship_template->getName() != template_name)
    {
        // Attempt to align the object's template to its reported template name.
        ship_template = ShipTemplate::getTemplate(template_name);

        // If the template still doesn't exist, destroy the object.
        if (!ship_template)
        {
            LOG(ERROR) << "ShipTemplateBasedObject with ID " << string(getMultiplayerId()) << " lacked a template, so it was destroyed.";
            destroy();
            return;
        }

        // If it does exist, set up its collider and model.
        ship_template->setCollisionData(this);
        model_info.setData(ship_template->model_data);
    }
}

std::unordered_map<string, string> ShipTemplateBasedObject::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret[trMark("gm_info", "CallSign")] = callsign;
    ret[trMark("gm_info", "Type")] = type_name;
    //ret[trMark("gm_info", "Hull")] = string(hull_strength) + "/" + string(hull_max);
    //for(int n=0; n<shield_count; n++) {
        // Note, translators: this is a compromise.
        // Because of the deferred translation the variable parameter can't be forwarded, so it'll always be a suffix.
    //    ret[trMark("gm_info", "Shield") + string(n + 1)] = string(shield_level[n]) + "/" + string(shield_max[n]);
    //}
    return ret;
}

bool ShipTemplateBasedObject::hasShield()
{
    return entity.hasComponent<Shields>();
}

void ShipTemplateBasedObject::takeDamage(float damage_amount, DamageInfo info)
{
    auto shields = entity.getComponent<Shields>();
    if (shields && shields->active) {
        float angle = angleDifference(getRotation(), vec2ToAngle(info.location - getPosition()));
        if (angle < 0)
            angle += 360.0f;
        float arc = 360.0f / float(shields->count);
        int shield_index = int((angle + arc / 2.0f) / arc);
        shield_index %= shields->count;
        auto& shield = shields->entry[shield_index];

        float shield_damage = damage_amount * getShieldDamageFactor(info, shield_index);
        damage_amount -= shield.level;
        shield.level -= shield_damage;
        if (shield.level < 0)
        {
            shield.level = 0.0;
        } else {
            shield.hit_effect = 1.0;
        }
        if (damage_amount < 0.0f)
        {
            damage_amount = 0.0;
        }
    }

    if (info.type != DT_EMP && damage_amount > 0.0f)
    {
        takeHullDamage(damage_amount, info);
    }

    auto hull = entity.getComponent<Hull>();
    if (hull && hull->current > 0)
    {
        if (hull->on_taking_damage.isSet())
        {
            if (info.instigator)
            {
                hull->on_taking_damage.call<void>(P<ShipTemplateBasedObject>(this), P<SpaceObject>(info.instigator));
            } else {
                hull->on_taking_damage.call<void>(P<ShipTemplateBasedObject>(this));
            }
        }
    }
}

void ShipTemplateBasedObject::takeHullDamage(float damage_amount, DamageInfo& info)
{
    auto hull = entity.getComponent<Hull>();
    if (!hull)
        return;
    hull->current -= damage_amount;
    if (hull->current <= 0.0f && !hull->allow_destruction)
    {
        hull->current = 1;
    }
    if (hull->current <= 0.0f)
    {
        destroyedByDamage(info);
        if (hull->on_destruction.isSet())
        {
            if (info.instigator)
            {
                hull->on_destruction.call<void>(P<ShipTemplateBasedObject>(this), P<SpaceObject>(info.instigator));
            } else {
                hull->on_destruction.call<void>(P<ShipTemplateBasedObject>(this));
            }
        }
        destroy();
    }
}

float ShipTemplateBasedObject::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    return 1.0f;
}

void ShipTemplateBasedObject::setCanBeDestroyed(bool enabled) { /*TODO*/ }
bool ShipTemplateBasedObject::getCanBeDestroyed() { return true; }

float ShipTemplateBasedObject::getHull() { return 0.0f; /*TODO*/ }
float ShipTemplateBasedObject::getHullMax() { return 0.0f; /*TODO*/ }
void ShipTemplateBasedObject::setHull(float amount) { /*TODO*/ }
void ShipTemplateBasedObject::setHullMax(float amount) { /*TODO*/ }

void ShipTemplateBasedObject::setTemplate(string template_name)
{
    P<ShipTemplate> new_ship_template = ShipTemplate::getTemplate(template_name);
    this->template_name = template_name;
    ship_template = new_ship_template;
    type_name = template_name;

    // Set the ship's radar ranges.
    long_range_radar_range = ship_template->long_range_radar_range;
    short_range_radar_range = ship_template->short_range_radar_range;

    if (entity) {
        auto& hull = entity.getOrAddComponent<Hull>();
        hull.current = hull.max = ship_template->hull;

        if (ship_template->shield_count) {
            auto& shields = entity.getOrAddComponent<Shields>();
            shields.count = ship_template->shield_count;
            for(int n=0; n<shields.count; n++)
                shields.entry[n].max = shields.entry[n].level = ship_template->shield_level[n];
        }

        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.radius = ship_template->model_data->getRadius() * 0.8f;
        trace.icon = ship_template->radar_trace;
        trace.max_size = 1024;
        trace.flags |= RadarTrace::ColorByFaction;

        if (!ship_template->external_dock_classes.empty())
            entity.getOrAddComponent<DockingBay>().external_dock_classes = ship_template->external_dock_classes;
        if (!ship_template->internal_dock_classes.empty())
            entity.getOrAddComponent<DockingBay>().external_dock_classes = ship_template->internal_dock_classes;
        
        auto bay = entity.getComponent<DockingBay>();
        if (bay) {
            if (ship_template->shares_energy_with_docked)
                bay->flags |= DockingBay::ShareEnergy;
            if (ship_template->repair_docked)
                bay->flags |= DockingBay::Repair;
        }
        
        if (ship_template->can_dock) {
            if (!ship_template->getClass().empty())
                entity.getOrAddComponent<DockingPort>().dock_class = ship_template->getClass();
            if (!ship_template->getSubClass().empty())
                entity.getOrAddComponent<DockingPort>().dock_subclass = ship_template->getSubClass();
        }
    }

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);

    //Call the virtual applyTemplateValues function so subclasses can get extra values from the ship templates.
    applyTemplateValues();
}

void ShipTemplateBasedObject::setShields(const std::vector<float>& amounts)
{
    //TODO
}

void ShipTemplateBasedObject::setShieldsMax(const std::vector<float>& amounts)
{
    //TODO
}

void ShipTemplateBasedObject::setRadarTrace(string trace)
{
    if (!entity) return;
    entity.getOrAddComponent<RadarTrace>().icon = "radar/" + trace;
}

void ShipTemplateBasedObject::setImpulseSoundFile(string sound)
{
    //TODO
}

bool ShipTemplateBasedObject::getSharesEnergyWithDocked()
{
    return false;//TODO
}
void ShipTemplateBasedObject::setSharesEnergyWithDocked(bool enabled) { /*TODO*/ }
bool ShipTemplateBasedObject::getRepairDocked()
{
    return false;//TODO
}
void ShipTemplateBasedObject::setRepairDocked(bool enabled) { /*TODO*/ }
bool ShipTemplateBasedObject::getRestocksScanProbes()
{
    return false;//TODO
}
void ShipTemplateBasedObject::setRestocksScanProbes(bool enabled) { /*TODO*/ }
bool ShipTemplateBasedObject::getRestocksMissilesDocked()
{
    return false;//TODO
}
void ShipTemplateBasedObject::setRestocksMissilesDocked(bool enabled) { /*TODO*/ }

void ShipTemplateBasedObject::onTakingDamage(ScriptSimpleCallback callback)
{
    auto hull = entity.getComponent<Hull>();
    if (hull)
        hull->on_taking_damage = callback;
}

void ShipTemplateBasedObject::onDestruction(ScriptSimpleCallback callback)
{
    auto hull = entity.getComponent<Hull>();
    if (hull)
        hull->on_destruction = callback;
}

string ShipTemplateBasedObject::getShieldDataString()
{
    string data = "";
    /* TODO
    for(int n=0; n<shield_count; n++)
    {
        if (n > 0)
            data += ":";
        data += string(int(shield_level[n]));
    }
    */
    return data;
}
