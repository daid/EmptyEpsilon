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

/// An Artifact is a configurable SpaceObject that can interact with other objects via collisions or scripting.
/// Use this to define arbitrary objects or collectible pickups in scenario scripts.
/// Example: artifact = Artifact():setModel("artifact6"):setSpin(0.5)
REGISTER_SCRIPT_SUBCLASS(Artifact, SpaceObject)
{
    /// Sets the 3D model used for this artifact, by its ModelData name.
    /// ModelData is defined in scripts/model_data.lua.
    /// Defaults to a ModelData whose name starts with "artifact" and ends with a random number between 1 and 8.
    /// Example: artifact:setModel("artifact6")
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setModel);
    /// Immediately destroys this artifact with a visual explosion.
    /// Example: artifact:explode() -- artifact is destroyed
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, explode);
    /// Defines whether this artifact can be picked up via collision.
    /// The artifact is destroyed upon being picked up.
    /// Defaults to false.
    /// Example: artifact:allowPickup(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, allowPickup);
    /// Defines a function to call every tick when a SpaceObject is colliding with the artifact.
    /// Passes the artifact and colliding SpaceObject to the called function.
    /// Example: artifact:onCollision(function(artifact, collider) print("Collision occurred") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onCollision);
    /// Defines a function to call every tick when a PlayerSpaceship is colliding with the artifact.
    /// Passes the artifact and colliding PlayerSpaceship to the called function.
    /// Example: artifact:onCollision(function(artifact, player) print("Collision occurred") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPlayerCollision);
    /// Defines a function to call once when a PlayerSpaceship collides with the artifact and allowPickup is enabled.
    /// Passes the artifact and colliding PlayerSpaceship to the called function.
    /// Example: artifact:onPickUp(function(artifact, player) print("Artifact retrieved") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPickUp);
    /// Alias of Artifact:onPickUp().
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPickup);
    /// Defines whether the artifact rotates, and if so at what rotational velocity. (unit?)
    /// For reference, normal asteroids spin at a rate between 0.1 and 0.8.
    /// Example: artifact:setSpin(0.5)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setSpin);
    /// Sets the radar trace image for this artifact.
    /// Optional. Defaults to "blip.png".
    /// Valid values are filenames to PNG files relative to resources/radar/.
    /// Example: artifact:setRadarTraceIcon("arrow.png") -- displays an arrow instead of a blip for this artifact
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setRadarTraceIcon);
    /// Scales the radar trace for this artifact.
    /// A value of 0 restores standard autoscaling relative to the artifact's radius.
    /// Set to 1 to mimic ship traces.
    /// Example: artifact:setRadarTraceScale(0.7)
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setRadarTraceScale);
    /// Sets the color of this artifact's radar trace.
    /// Optional. Defaults to solid white (255,255,255)
    /// Example: artifact:setRadarTraceColor(255,200,100) -- mimics an asteroid
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
    auto& pickup = entity.getOrAddComponent<PickupCallback>();
    pickup.callback = callback;
}

void Artifact::onCollision(ScriptSimpleCallback callback)
{
    auto& cb = entity.getOrAddComponent<CollisionCallback>();
    cb.player = false;
    cb.callback = callback;
}

void Artifact::onPlayerCollision(ScriptSimpleCallback callback)
{
    auto& cb = entity.getOrAddComponent<CollisionCallback>();
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
