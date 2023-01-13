#include <graphics/opengl.h>
#include "artifact.h"
#include "explosionEffect.h"
#include "playerSpaceship.h"
#include "main.h"
#include "random.h"
#include "components/pickup.h"
#include "components/spin.h"

#include <glm/ext/matrix_transform.hpp>

#include "scriptInterface.h"

/// An artifact.
/// Can be used for mission scripting.
REGISTER_SCRIPT_SUBCLASS(Artifact, SpaceObject)
{
    /// Set the 3D model used for this artifact.
    /// Example: setModel("artifact6"), setModel("shield_generator"), setModel("ammo_box").
    /// Check model_data.lua for all possible options.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setModel);
    /// Have this object explode with a visual explosion. The Artifact is destroyed by this action.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, explode);
    /// Set if this artifact can be picked up or not. When it is picked up, this artifact will be destroyed.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, allowPickup);
    /// Set a function that will be called every tick when a SpaceObject is
    /// colliding with the artifact.
    /// Passes the artifact and colliding SpaceObject.
    /// Example:
    /// artifact:onCollision(function(artifact, collider) print("Collision occurred") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onCollision);
    /// Set a function that will be called every tick when a PlayerSpaceship is
    /// colliding with the artifact.
    /// Passes the artifact and colliding PlayerSpaceship.
    /// Example:
    /// artifact:onCollision(function(artifact, player) print("Collision occurred") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPlayerCollision);
    /// Set a function that will be called once when a PlayerSpaceship collides
    /// with the artifact while allowPickup is enabled. The artifact is
    /// subsequently destroyed.
    /// Passes the artifact and colliding PlayerSpaceship.
    /// Example:
    /// artifact:onPickUp(function(artifact, player) print("Artifact retrieved") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPickUp);
    /// Alias of onPickUp.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPickup);
    /// Let the artifact rotate. For reference, normal asteroids in the game have spins between 0.1 and 0.8.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setSpin);
    /// Set the icon to be used for this artifact on the radar.
    /// For example, artifact:setRadarTraceIcon("arrow.png") will show an arrow instead of a dot for this artifact.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setRadarTraceIcon);
    /// Scales the radar trace. Setting to 0 restores to standard autoscaling.
    /// Setting to 1 is needed for mimicking ship traces.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setRadarTraceScale);
    /// Sets the color of the radar trace.
    /// Example: 255,200,100 for mimicking asteroids.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setRadarTraceColor);
}

REGISTER_MULTIPLAYER_CLASS(Artifact, "Artifact");
Artifact::Artifact()
: SpaceObject(120, "Artifact"),
  current_model_data_name("artifact" + string(irandom(1, 8))),
  model_data_name(current_model_data_name)
{
    setRotation(random(0, 360));
    model_info.setData(current_model_data_name);

    registerMemberReplication(&model_data_name);

    if (entity) {
        auto& trace = entity.getOrAddComponent<RadarTrace>();
        trace.radius = 120.0f;
        trace.icon = "radar/blip.png";
    }
}

void Artifact::update(float delta)
{
    if (current_model_data_name != model_data_name)
    {
        current_model_data_name = model_data_name;
        model_info.setData(current_model_data_name);
    }
}

void Artifact::setModel(string model_name)
{
    model_data_name = model_name;
}

void Artifact::explode()
{
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(120);
    e->setPosition(getPosition());
    destroy();
}

void Artifact::allowPickup(bool allow)
{
    if (allow)
        entity.getOrAddComponent<PickupCallback>();
    else
        entity.removeComponent<PickupCallback>();
}

void Artifact::setSpin(float spin)
{
    if (spin == 0.0f)
        entity.removeComponent<Spin>();
    else
        entity.getOrAddComponent<Spin>().rate = spin;
}

void Artifact::setRadarTraceIcon(string icon)
{
    auto trace = entity.getComponent<RadarTrace>();
    if (trace) {
        trace->icon = "radar/" + icon;
    }
}

void Artifact::setRadarTraceScale(float scale)
{
    auto trace = entity.getComponent<RadarTrace>();
    if (trace) {
        trace->min_size = scale * 32.0f;
        trace->max_size = scale * 32.0f;
    }
}

void Artifact::setRadarTraceColor(int r, int g, int b)
{
    auto trace = entity.getComponent<RadarTrace>();
    if (trace) {
        trace->color = glm::u8vec4(r, g, b, 255);
    }
}

void Artifact::onPickUp(ScriptSimpleCallback callback)
{
    auto pickup = entity.getOrAddComponent<PickupCallback>();
    pickup.callback = callback;
}

void Artifact::onCollision(ScriptSimpleCallback callback)
{
    auto cb = entity.getOrAddComponent<CollisionCallback>();
    cb.player = false;
    cb.callback = callback;
}

void Artifact::onPlayerCollision(ScriptSimpleCallback callback)
{
    auto cb = entity.getOrAddComponent<CollisionCallback>();
    cb.player = true;
    cb.callback = callback;
}

string Artifact::getExportLine()
{
    string ret = "Artifact():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    ret += ":setModel(\"" + model_data_name + "\")";
    //if (allow_pickup)
    //    ret += ":allowPickup(true)";
    return ret;
}
