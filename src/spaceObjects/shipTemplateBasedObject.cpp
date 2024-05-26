#include "shipTemplateBasedObject.h"

#include "scriptInterface.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/hull.h"
#include "components/shields.h"
#include "components/rendering.h"

#include "tween.h"
#include "i18n.h"

/// A ShipTemplateBasedObject (STBO) is an object class created from a ShipTemplate.
/// This is the parent class of SpaceShip (CpuShip, PlayerSpaceship) and SpaceStation objects, which inherit all STBO functions and can be created by scripts.
/// Objects of this class can't be created by scripts, but SpaceStation and child classes of SpaceShip can.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(ShipTemplateBasedObject, SpaceObject)
{
    /// Sets this ShipTemplate that defines this STBO's traits, and then applies them to this STBO.
    /// ShipTemplates define the STBO's class, weapons, hull and shield strength, 3D appearance, and more.
    /// See the ShipTemplate class for details, and files in scripts/shiptemplates/ for the default templates.
    /// WARNING: Using a string that is not a valid ShipTemplate name crashes the game!
    /// ShipTemplate string names are case-sensitive.
    /// Examples:
    /// CpuShip():setTemplate("Phobos T3")
    /// PlayerSpaceship():setTemplate("Phobos M3P")
    /// SpaceStation():setTemplate("Large Station")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTemplate);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setTemplate().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShipTemplate);
    /// Sets this STBO's vessel classification name, such as "Starfighter" or "Cruiser".
    /// This overrides the vessel class name provided by the ShipTemplate.
    /// Example: stbo:setTypeName("Prototype")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTypeName);
    /// Returns this STBO's vessel classification name.
    /// Example:
    /// stbo:setTypeName("Prototype")
    /// stbo:getTypeName() -- returns "Prototype"
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getTypeName);
    /// Returns this STBO's hull points.
    /// Example: stbo:getHull()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHull);
    /// Returns this STBO's maximum limit of hull points.
    /// Example: stbo:getHullMax()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHullMax);
    /// Sets this STBO's hull points.
    /// If set to a value larger than the maximum, this sets the value to the limit.
    /// If set to a value less than 0, this sets the value to 0.
    /// Note that setting this value to 0 doesn't immediately destroy the STBO.
    /// Example: stbo:setHull(100) -- sets the hull point limit to either 100, or the limit if less than 100
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHull);
    /// Sets this STBO's maximum limit of hull points.
    /// Note that SpaceStations can't repair their own hull, so this only changes the percentage of remaining hull.
    /// Example: stbo:setHullMax(100) -- sets the hull point limit to 100
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHullMax);
    /// Defines whether this STBO can be destroyed by damage.
    /// Defaults to true.
    /// Example: stbo:setCanBeDestroyed(false) -- prevents the STBO from being destroyed by damage
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setCanBeDestroyed);
    /// Returns whether the STBO can be destroyed by damage.
    /// Example: stbo:getCanBeDestroyed()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getCanBeDestroyed);
    /// Returns the shield points for this STBO's shield segment with the given index.
    /// Shield segments are 0-indexed.
    /// Example for a ship with two shield segments:
    /// stbo:getShieldLevel(0) -- returns front shield points
    /// stbo:getShieldLevel(1) -- returns rear shield points
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldLevel);
    /// Returns this STBO's number of shield segments.
    /// Each segment divides the 360-degree shield arc equally for each segment, up to a maximum of 8 segments.
    /// The segments' order starts with the front-facing segment, then proceeds clockwise.
    /// Example: stbo:getShieldCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldCount);
    /// Returns the maximum shield points for the STBO's shield segment with the given index.
    /// Example: stbo:getShieldMax(0) -- returns the max shield strength for segment 0
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldMax);
    /// Sets this STBO's shield points.
    /// Each number provided as a parameter sets the points for a corresponding shield segment.
    /// Note that the segments' order starts with the front-facing segment, then proceeds clockwise.
    /// If more parameters are provided than the ship has shield segments, the excess parameters are discarded.
    /// Example:
    /// -- On a ship with 4 segments, this sets the forward shield segment to 50, right to 40, rear 30, left 20
    /// -- On a ship with 2 segments, this sets forward 50, rear 40
    /// stbo:setShields(50,40,30,20)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShields);
    /// Sets this STBO's maximum shield points per segment, and can also create new segments.
    /// The number of parameters defines the STBO's number of shield segments, to a maximum of 8 segments.
    /// The segments' order starts with the front-facing segment, then proceeds clockwise.
    /// If more parameters are provided than the STBO has shield segments, the excess parameters create new segments with the defined max but 0 current shield points.
    /// A STBO with one shield segment has only a front shield generator system, and a STBO with two or more segments has only front and rear generator systems.
    /// Setting a lower maximum points value than the segment's current number of points also reduces the points to the limit.
    /// However, increasing the maximum value to a higher value than the current points does NOT automatically increase the current points,
    /// which requires a separate call to ShipTemplateBasedObject:setShield().
    /// Example:
    /// -- On a ship with 4 segments, this sets the forward shield max to 50, right to 40, rear 30, left 20
    /// -- On a ship with 2 segments, this does the same, but its current rear shield points become right shield points, and the new rear and left shield segments have 0 points
    /// stbo:setShieldsMax(50,40,30,20)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShieldsMax);
    /// Sets this STBO's trace image.
    /// Valid values are filenames of PNG images relative to the resources/radar directory.
    /// Radar trace images should be white with a transparent background.
    /// Example: stbo:setRadarTrace("arrow.png") -- sets the radar trace to resources/radar/arrow.png
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRadarTrace);
    /// Sets this STBO's impulse engine sound effect.
    /// Valid values are filenames of WAV files relative to the resources/ directory.
    /// Use a looping sound file that tolerates being pitched up and down as the ship's impulse speed changes.
    /// Example: stbo:setImpulseSoundFile("sfx/engine_fighter.wav") -- sets the impulse sound to resources/sfx/engine_fighter.wav
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setImpulseSoundFile);
    /// Defines whether this STBO's shields are activated.
    /// Always returns true except for PlayerSpaceships, because only players can deactivate shields.
    /// Example stbo:getShieldsActive() -- returns true if up, false if down
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldsActive);
    /// Returns whether this STBO supplies energy to docked PlayerSpaceships.
    /// Example: stbo:getSharesEnergyWithDocked()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getSharesEnergyWithDocked);
    /// Defines whether this STBO supplies energy to docked PlayerSpaceships.
    /// Example: stbo:getSharesEnergyWithDocked(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setSharesEnergyWithDocked);
    /// Returns whether this STBO repairs docked SpaceShips.
    /// Example: stbo:getRepairDocked()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRepairDocked);
    /// Defines whether this STBO repairs docked SpaceShips.
    /// Example: stbo:setRepairDocked(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRepairDocked);
    /// Returns whether the STBO restocks scan probes for docked PlayerSpaceships.
    /// Example: stbo:getRestocksScanProbes()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksScanProbes);
    /// Defines whether the STBO restocks scan probes for docked PlayerSpaceships.
    /// Example: stbo:setRestocksScanProbes(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksScanProbes);
    /// Returns whether this STBO restocks missiles for docked CpuShips.
    /// Example: stbo:getRestocksMissilesDocked()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksMissilesDocked);
    /// Defines whether this STBO restocks missiles for docked CpuShips.
    /// To restock docked PlayerSpaceships' weapons, use a comms script. See ShipTemplateBasedObject:setCommsScript() and :setCommsFunction().
    /// Example: stbo:setRestocksMissilesDocked(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksMissilesDocked);
    /// Returns this STBO's long-range radar range.
    /// Example: stbo:getLongRangeRadarRange()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getLongRangeRadarRange);
    /// Sets this STBO's long-range radar range.
    /// PlayerSpaceships use this range on the science and operations screens' radar.
    /// AI orders of CpuShips use this range to detect potential targets.
    /// Example: stbo:setLongRangeRadarRange(20000) -- sets the long-range radar range to 20U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setLongRangeRadarRange);
    /// Returns this STBO's short-range radar range.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShortRangeRadarRange);
    /// Sets this STBO's short-range radar range.
    /// PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
    /// AI orders of CpuShips use this range to decide when to disengage pursuit of fleeing targets.
    /// This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
    /// Example: stbo:setShortRangeRadarRange(4000) -- sets the short-range radar range to 4U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShortRangeRadarRange);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:getShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShieldMax);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShieldMax);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:getShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShieldMax);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShieldMax);
    /// Defines a function to call when this STBO takes damage.
    /// Passes the object taking damage and the instigator SpaceObject (or nil) to the function.
    /// Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was damaged by " .. instigator:getCallSign()) end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onTakingDamage);
    /// Defines a function to call when this STBO is destroyed by taking damage.
    /// Passes the object taking damage and the instigator SpaceObject that delivered the destroying damage (or nil) to the function.
    /// Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was destroyed by " .. instigator:getCallSign()) end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onDestruction);
}

ShipTemplateBasedObject::ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: SpaceObject(collision_range, multiplayer_name, multiplayer_significant_range)
{
    entity.getOrAddComponent<sp::Physics>().setCircle(sp::Physics::Type::Dynamic, collision_range);

    registerMemberReplication(&template_name);

    setCallSign("[" + string(getMultiplayerId()) + "]");
}

void ShipTemplateBasedObject::draw3DTransparent()
{
    auto shields = entity.getComponent<Shields>();
    if (!shields || shields->entries.empty())
        return;

    float angle = 0.0;
    float arc = 360.0f / shields->entries.size();
    const auto model_matrix = getModelMatrix();
    for(auto& shield : shields->entries)
    {
        if (shield.hit_effect > 0)
        {
            if (shields->entries.size() > 1)
            {
                //TODO: model_info.renderShield(model_matrix, (shields->entry[n].level / shields->entry[n].max) * shields->entry[n].hit_effect, angle);
            }else{
                //TODO: model_info.renderShield(model_matrix, (shields->entry[n].level / shields->entry[n].max) * shields->entry[n].hit_effect);
            }
        }
        angle += arc;
    }
}

void ShipTemplateBasedObject::update(float delta)
{
    /*
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
        //model_info.setData(ship_template->model_data);
    }
    */
}

bool ShipTemplateBasedObject::hasShield()
{
    return entity.hasComponent<Shields>();
}

void ShipTemplateBasedObject::setCanBeDestroyed(bool enabled) { /*TODO*/ }
bool ShipTemplateBasedObject::getCanBeDestroyed() { return true; }

float ShipTemplateBasedObject::getHull() { return 0.0f; /*TODO*/ }
float ShipTemplateBasedObject::getHullMax() { return 0.0f; /*TODO*/ }
void ShipTemplateBasedObject::setHull(float amount) { /*TODO*/ }
void ShipTemplateBasedObject::setHullMax(float amount) { /*TODO*/ }

void ShipTemplateBasedObject::setTemplate(string template_name)
{
    /*
    P<ShipTemplate> new_ship_template = ShipTemplate::getTemplate(template_name);
    if (!new_ship_template) return;
    this->template_name = template_name;
    ship_template = new_ship_template;
    setTypeName(template_name);

    if (entity) {
        auto& lrr = entity.getOrAddComponent<LongRangeRadar>();
        // Set the ship's radar ranges.
        lrr.long_range = ship_template->long_range_radar_range;
        lrr.short_range = ship_template->short_range_radar_range;

        auto& hull = entity.getOrAddComponent<Hull>();
        hull.current = hull.max = ship_template->hull;

        if (ship_template->shield_count) {
            auto& shields = entity.getOrAddComponent<Shields>();
            shields.entries.resize(ship_template->shield_count);
            for(unsigned int n=0; n<shields.entries.size(); n++)
                shields.entries[n].max = shields.entries[n].level = ship_template->shield_level[n];
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

        entity.getOrAddComponent<ShareShortRangeRadar>();

        auto& mrc = entity.getOrAddComponent<MeshRenderComponent>();
        mrc.mesh.name = ship_template->model_data->mesh_name;
        mrc.texture.name = ship_template->model_data->texture_name;
        mrc.specular_texture.name = ship_template->model_data->specular_texture_name;
        mrc.illumination_texture.name = ship_template->model_data->illumination_texture_name;
        mrc.scale = ship_template->model_data->scale;
        mrc.mesh_offset.x = ship_template->model_data->mesh_offset.x;
        mrc.mesh_offset.y = ship_template->model_data->mesh_offset.y;
        mrc.mesh_offset.z = ship_template->model_data->mesh_offset.z;

        auto& ee = entity.getOrAddComponent<EngineEmitter>();
        for(const auto& mde : ship_template->model_data->engine_emitters) {
            EngineEmitter::Emitter e;
            e.position = mde.position * ship_template->model_data->scale;
            e.color = mde.color;
            e.scale = mde.scale * ship_template->model_data->scale;
            ee.emitters.push_back(e);
        }
    }

    ship_template->setCollisionData(this);

    //Call the virtual applyTemplateValues function so subclasses can get extra values from the ship templates.
    applyTemplateValues();
    */
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
    //if (hull)
    //    hull->on_taking_damage = callback;
}

void ShipTemplateBasedObject::onDestruction(ScriptSimpleCallback callback)
{
    auto hull = entity.getComponent<Hull>();
    //if (hull)
    //    hull->on_destruction = callback;
}

string ShipTemplateBasedObject::getShieldDataString()
{
    string data = "";
    /* TODO
    for(int n=0; n<shield_count; n++)
    {
        if (n > 0)
            data += ":";
        data += string(int(shield_level[n])) + "/" + string(int(shield_max[n]));
    }
    */
    return data;
}
