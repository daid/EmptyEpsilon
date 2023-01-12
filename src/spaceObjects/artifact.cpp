#include <graphics/opengl.h>
#include "artifact.h"
#include "explosionEffect.h"
#include "playerSpaceship.h"
#include "main.h"
#include "random.h"

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
  model_data_name(current_model_data_name),
  artifact_spin(0.0f),
  allow_pickup(false),
  radar_trace_icon("radar/blip.png"),
  radar_trace_scale(0),
  radar_trace_color(glm::u8vec4(255, 255, 255, 255))
{
    setRotation(random(0, 360));
    model_info.setData(current_model_data_name);

    registerMemberReplication(&model_data_name);
    registerMemberReplication(&artifact_spin);
    registerMemberReplication(&radar_trace_icon);
    registerMemberReplication(&radar_trace_scale);
    registerMemberReplication(&radar_trace_color);
}

void Artifact::update(float delta)
{
    if (current_model_data_name != model_data_name)
    {
        current_model_data_name = model_data_name;
        model_info.setData(current_model_data_name);
    }
}

void Artifact::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    // radar trace scaling, via script or automatically
    float size;
    if (radar_trace_scale > 0)
    {
        if (long_range)
            size = radar_trace_scale * 0.7f;
        else
            size = radar_trace_scale;
    }
    else
    {
        size = getRadius() * scale / 16;
        if (size < 0.2f)
            size = 0.2f;
    }
    renderer.drawRotatedSprite(radar_trace_icon, position, size * 32.0f, getRotation() - rotation, radar_trace_color);
}

void Artifact::collide(Collisionable* target, float force)
{
    // Handle collisions on the server only.
    if (!isServer())
    {
        return;
    }

    // Fire collision callbacks.
    P<SpaceObject> hit_object = P<Collisionable>(target);
    P<PlayerSpaceship> player = hit_object;

    // Player-specific callback handling.
    if (player)
    {
        if (allow_pickup)
        {
            // If the artifact is collectible, pick it up.
            if (on_pickup_callback.isSet())
            {
                on_pickup_callback.call<void>(P<Artifact>(this), player);
            }

            destroy();
        }
        else
        {
            // If the artifact isn't collectible, fire the collision callback.
            if (on_player_collision_callback.isSet())
            {
                on_player_collision_callback.call<void>(P<Artifact>(this), player);
            }
        }
    }

    // Fire the SpaceObject collision callback, if set.
    if (hit_object && on_collision_callback.isSet())
    {
        on_collision_callback.call<void>(P<Artifact>(this), hit_object);
    }
}

void Artifact::setModel(string model_name)
{
    model_data_name = model_name;
}

void Artifact::explode()
{
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(getRadius());
    e->setPosition(getPosition());
    destroy();
}

void Artifact::allowPickup(bool allow)
{
    allow_pickup = allow;
}

void Artifact::setSpin(float spin)
{
    artifact_spin = spin;
}

void Artifact::setRadarTraceIcon(string icon)
{
    radar_trace_icon = "radar/" + icon;
}

void Artifact::setRadarTraceScale(float scale)
{
    radar_trace_scale = scale;
}

void Artifact::onPickUp(ScriptSimpleCallback callback)
{
    this->allow_pickup = 1;
    this->on_pickup_callback = callback;
}

void Artifact::onCollision(ScriptSimpleCallback callback)
{
    this->on_collision_callback = callback;
}

void Artifact::onPlayerCollision(ScriptSimpleCallback callback)
{
    this->on_player_collision_callback = callback;
}

string Artifact::getExportLine()
{
    string ret = "Artifact():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    ret += ":setModel(\"" + model_data_name + "\")";
    if (allow_pickup)
        ret += ":allowPickup(true)";
    return ret;
}

glm::mat4 Artifact::getModelMatrix() const
{
    auto matrix = SpaceObject::getModelMatrix();

    if (artifact_spin != 0.f)
        matrix = glm::rotate(matrix, glm::radians(engine->getElapsedTime() * artifact_spin), glm::vec3(0.f, 0.f, 1.f));
    return matrix;
}
