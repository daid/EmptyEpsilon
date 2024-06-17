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


ShipTemplateBasedObject::ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: SpaceObject(collision_range, multiplayer_name, multiplayer_significant_range)
{
    entity.getOrAddComponent<sp::Physics>().setCircle(sp::Physics::Type::Dynamic, collision_range);

    registerMemberReplication(&template_name);

    setCallSign("[" + string(getMultiplayerId()) + "]");
}

void ShipTemplateBasedObject::draw3DTransparent()
{
    
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
