#include "missileWeapon.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

MissileWeapon::MissileWeapon(string multiplayer_name, const MissileWeaponData& data)
: SpaceObject(10, multiplayer_name), data(data)
{
    target_id = -1;
    target_angle = 0;
    category_modifier = 1;
    lifetime = data.lifetime;
    
    registerMemberReplication(&target_id);
    registerMemberReplication(&target_angle);
    registerMemberReplication(&category_modifier);

    launch_sound_played = false;
}

void MissileWeapon::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    if (long_range) return;

    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "RadarArrow.png");
    object_sprite.setRotation(getRotation()-rotation);
    object_sprite.setPosition(position);
    object_sprite.setColor(data.color);
    object_sprite.setScale(0.25 + 0.25 * category_modifier, 0.25 + 0.25 * category_modifier);
    window.draw(object_sprite);
}

void MissileWeapon::update(float delta)
{
    updateMovement();
    
    // Small missiles have a larger speed & rotational speed, large ones are slower and turn less fast
    float size_speed_modifier = 1 / category_modifier;

    if (!launch_sound_played)
    {
        soundManager->playSound(data.fire_sound, getPosition(), 200.0, 1.0, 1.0f + random(-0.2f, 0.2f));
        launch_sound_played = true;
    }
    
    // Since we do want the range to remain the same, ensure that slow missiles don't die down as fast.
    lifetime -= delta * size_speed_modifier;
    if (lifetime < 0)
    {
        lifeEnded();
        destroy();
    }
    setVelocity(sf::vector2FromAngle(getRotation()) * data.speed * size_speed_modifier);

    if (delta > 0)
    {
        ParticleEngine::spawn(sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(1, 0.8, 0.8), sf::Vector3f(0, 0, 0), 5, 20, 5.0);
    }
}

void MissileWeapon::collide(Collisionable* target, float force)
{
    if (!game_server)
    {
        return;
    }
    P<SpaceObject> object = P<Collisionable>(target);
    if (!object || object == owner || !object->canBeTargetedBy(owner))
    {
        return;
    }

    hitObject(object);
    destroy();
}

void MissileWeapon::updateMovement()
{
    if (data.turnrate > 0.0)
    {
        if (data.homing_range > 0)
        {
            P<SpaceObject> target;
            if (game_server)
            {
                target = game_server->getObjectById(target_id);
            }
            else
            {
                target = game_client->getObjectById(target_id);
            }

            if (target && (target->getPosition() - getPosition()) < data.homing_range + target->getRadius())
            {
                target_angle = sf::vector2ToAngle(target->getPosition() - getPosition());
            }
        }
        // Small missiles have a larger speed & rotational speed, large ones are slower and turn less fast
        float size_speed_modifier = 1 / category_modifier;

        float angle_diff = sf::angleDifference(getRotation(), target_angle);

        if (angle_diff > 1.0)
            setAngularVelocity(data.turnrate * size_speed_modifier);
        else if (angle_diff < -1.0)
            setAngularVelocity(data.turnrate * -1.0f * size_speed_modifier);
        else
            setAngularVelocity(angle_diff * data.turnrate * size_speed_modifier);
    }
}
