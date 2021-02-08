#include <SFML/OpenGL.hpp>
#include "artifact.h"
#include "explosionEffect.h"
#include "playerSpaceship.h"
#include "main.h"

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
    /// For example, artifact:setRadarTraceIcon("RadarArrow.png") will show an arrow instead of a dot for this artifact.
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
  model_data_name(current_model_data_name),
  artifact_spin(0.0f),
  allow_pickup(false),
  radar_trace_icon("RadarBlip.png"),
  radar_trace_scale(0),
  radar_trace_color(sf::Color(255, 255, 255))
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

void Artifact::draw3D()
{
#if FEATURE_3D_RENDERING
    if (artifact_spin != 0.0) {
        glRotatef(engine->getElapsedTime() * artifact_spin, 0, 0, 1);
    }
    SpaceObject::draw3D();
#endif//FEATURE_3D_RENDERING
}

void Artifact::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, radar_trace_icon);
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    object_sprite.setColor(radar_trace_color);
    // radar trace scaling, via script or automatically
    float size;
    if (radar_trace_scale > 0)
    {
        if (long_range)
            size =radar_trace_scale * 0.7;
        else
            size = radar_trace_scale;
    }
    else
    {
        size = getRadius() * scale / object_sprite.getTextureRect().width * 2;
        if (size < 0.2)
            size = 0.2;
    }
    object_sprite.setScale(size, size);
    window.draw(object_sprite);
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
                on_pickup_callback.call(P<Artifact>(this), player);
            }

            destroy();
        }
        else
        {
            // If the artifact isn't collectible, fire the collision callback.
            if (on_player_collision_callback.isSet())
            {
                on_player_collision_callback.call(P<Artifact>(this), player);
            }
        }
    }

    // Fire the SpaceObject collision callback, if set.
    if (hit_object && on_collision_callback.isSet())
    {
        on_collision_callback.call(P<Artifact>(this), hit_object);
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
    radar_trace_icon = icon;
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
