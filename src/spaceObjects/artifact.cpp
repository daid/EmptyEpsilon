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
    /// Set a function that will be called if a player picks up the artifact.
    /// First argument given to the function will be the artifact, the second the player.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, onPickUp);
    /// Let the artifact rotate. For reference, normal asteroids in the game have spins between 0.1 and 0.8.
    REGISTER_SCRIPT_CLASS_FUNCTION(Artifact, setSpin);
}

REGISTER_MULTIPLAYER_CLASS(Artifact, "Artifact");
Artifact::Artifact()
: SpaceObject(120, "Artifact")
{
    registerMemberReplication(&model_data_name);
    registerMemberReplication(&artifact_spin);

    setRotation(random(0, 360));

    current_model_data_name = "artifact" + string(irandom(1, 8));
    model_data_name = current_model_data_name;
    model_info.setData(current_model_data_name);

    allow_pickup = false;
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
    textureManager.setTexture(object_sprite, "RadarBlip.png");
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    object_sprite.setColor(sf::Color(255, 255, 255));
    float size = getRadius() * scale / object_sprite.getTextureRect().width * 2;
    if (size < 0.2)
        size = 0.2;
    object_sprite.setScale(size, size);
    window.draw(object_sprite);
}

std::unordered_map<string, string> Artifact::getGMInfo()
{
    std::unordered_map<string, string> ret = SpaceObject::getGMInfo();
    ret["allowPickup"] = string(allow_pickup);
    return ret;
}

void Artifact::collide(Collisionable* target, float force)
{
    if (!isServer() || !allow_pickup)
        return;
    P<SpaceObject> hit_object = P<Collisionable>(target);
    P<PlayerSpaceship> player = hit_object;
    if (player)
    {
        if (on_pickup_callback.isSet())
        {
            on_pickup_callback.call(P<Artifact>(this), player);
        }
        destroy();
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

void Artifact::onPickUp(ScriptSimpleCallback callback)
{
    this->allow_pickup = 1;
    this->on_pickup_callback = callback;
}

string Artifact::getExportLine()
{
    string ret = "Artifact():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    ret += ":setModel(\"" + model_data_name + "\")";
    if (allow_pickup)
        ret += ":allowPickup(true)";
    return ret;
}
