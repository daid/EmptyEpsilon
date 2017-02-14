#include "missileWeapon.h"
#include "particleEffect.h"
#include "explosionEffect.h"

MissileWeapon::MissileWeapon(string multiplayerName, const MissileWeaponData& data)
: SpaceObject(10, multiplayerName), data(data)
{
    target_id = -1;
    target_angle = 0;
    lifetime = data.lifetime;
    
    registerMemberReplication(&target_id);
    registerMemberReplication(&target_angle);

    launch_sound_played = false;
}

void MissileWeapon::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (long_range) return;

    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarArrow.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setColor(data.color);
    objectSprite.setScale(0.5, 0.5);
    window.draw(objectSprite);
}

void MissileWeapon::update(float delta)
{
    updateMovement();

    if (!launch_sound_played)
    {
        soundManager->playSound("missile_launch.wav", getPosition(), 200.0, 1.0);
        launch_sound_played = true;
    }
    lifetime -= delta;
    if (lifetime < 0)
    {
        lifeEnded();
        destroy();
    }
    setVelocity(sf::vector2FromAngle(getRotation()) * data.speed);

    if (delta > 0)
        ParticleEngine::spawn(sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(1, 0.8, 0.8), sf::Vector3f(0, 0, 0), 5, 20, 5.0);
}

void MissileWeapon::collide(Collisionable* target, float force)
{
    if (!game_server)
        return;
    P<SpaceObject> object = P<Collisionable>(target);
    if (!object || object == owner || !object->canBeTargetedBy(owner))
        return;

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
                target = game_server->getObjectById(target_id);
            else
                target = game_client->getObjectById(target_id);

            if (target && (target->getPosition() - getPosition()) < data.homing_range + target->getRadius())
            {
                target_angle = sf::vector2ToAngle(target->getPosition() - getPosition());
            }
        }

        float angleDiff = sf::angleDifference(getRotation(), target_angle);

        if (angleDiff > 1.0)
            setAngularVelocity(data.turnrate);
        else if (angleDiff < -1.0)
            setAngularVelocity(data.turnrate * -1.0f);
        else
            setAngularVelocity(angleDiff * data.turnrate);
    }
}
