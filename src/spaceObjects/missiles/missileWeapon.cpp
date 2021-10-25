#include "missileWeapon.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"
#include "random.h"
#include "multiplayer_server.h"
#include "multiplayer_client.h"
#include "soundManager.h"

#include "i18n.h"


/// Base class for every missile (mines are not missiles)
/// You cannot create a missile in script with this class, use derived classes
/// like HomingMissile, HVLI etc.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(MissileWeapon, SpaceObject)
{
  /// Get the missile's owner's object.
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getOwner);
  /// Get the missile's target object.
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getTarget);
  /// Must be an existing target, else does nothing. It does not check if really targetable or not.
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, setTarget);
  /// Lifetime is a number in seconds
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getLifetime);
  /// Lifetime is a number in seconds
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, setLifetime);
  /// Set the missile size as for tube size.
  /// Valid sizes: see EMissileSizes
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getMissileSize);
  /// Get the missile size as for tube size.
  /// Valid sizes: see EMissileSizes
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, setMissileSize);
}

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

void MissileWeapon::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (long_range) return;

    renderer.drawRotatedSprite("radar/arrow.png", position, 32 * (0.25f + 0.25f * category_modifier), getRotation()-rotation, data.color);
}

void MissileWeapon::update(float delta)
{
    updateMovement();

    // Small missiles have a larger speed & rotational speed, large ones are slower and turn less fast
    float size_speed_modifier = 1 / category_modifier;

    if (!launch_sound_played)
    {
        soundManager->playSound(data.fire_sound, getPosition(), 400.0, 60.0, (1.0f + random(-0.2f, 0.2f)) * size_speed_modifier);
        launch_sound_played = true;
    }

    // Since we do want the range to remain the same, ensure that slow missiles don't die down as fast.
    lifetime -= delta * size_speed_modifier;
    if (lifetime < 0 && isServer())
    {
        lifeEnded();
        destroy();
    }
    setVelocity(vec2FromAngle(getRotation()) * data.speed * size_speed_modifier);

    if (delta > 0)
    {
        ParticleEngine::spawn(glm::vec3(getPosition().x, getPosition().y, 0), glm::vec3(getPosition().x, getPosition().y, 0), glm::vec3(1, 0.8, 0.8), glm::vec3(0, 0, 0), 5, 20, 5.0);
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
    if (data.turnrate > 0.0f)
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

            if (target)
            {
                float r = data.homing_range + target->getRadius();
                if (glm::length2(target->getPosition() - getPosition()) < r*r)
                {
                    target_angle = vec2ToAngle(target->getPosition() - getPosition());
                }
            }
        }
        // Small missiles have a larger speed & rotational speed, large ones are slower and turn less fast
        float size_speed_modifier = 1 / category_modifier;

        float angle_diff = angleDifference(getRotation(), target_angle);

        if (angle_diff > 1.0f)
            setAngularVelocity(data.turnrate * size_speed_modifier);
        else if (angle_diff < -1.0f)
            setAngularVelocity(data.turnrate * -1.0f * size_speed_modifier);
        else
            setAngularVelocity(angle_diff * data.turnrate * size_speed_modifier);
    }
}

P<SpaceObject> MissileWeapon::getOwner()
{
    // Owner is assigned by the weapon tube upon firing.
    if (game_server)
    {
        return owner;
    }

    LOG(ERROR) << "MissileWeapon::getOwner(): owner not replicated to clients.";
    return nullptr;
}

P<SpaceObject> MissileWeapon::getTarget()
{
    if (game_server)
        return game_server->getObjectById(target_id);
    return game_client->getObjectById(target_id);
}

void MissileWeapon::setTarget(P<SpaceObject> target)
{
    if (!target)
    {
        return;
    }
    target_id = target->getMultiplayerId();
}

float MissileWeapon::getLifetime()
{
    return lifetime;
}

void MissileWeapon::setLifetime(float lifetime)
{
    this->lifetime = lifetime;
}

EMissileSizes MissileWeapon::getMissileSize()
{
    return MissileWeaponData::convertCategoryModifierToSize(category_modifier);
}

void MissileWeapon::setMissileSize(EMissileSizes missile_size)
{
    category_modifier = MissileWeaponData::convertSizeToCategoryModifier(missile_size);
}

std::unordered_map<string, string> MissileWeapon::getGMInfo()
{
    std::unordered_map<string, string> ret;

    if (owner)
    {
        ret[trMark("gm_info", "Owner")] = owner->getCallSign();
    }

    P<SpaceObject> target = game_server->getObjectById(target_id);

    if (target)
    {
        ret[trMark("gm_info", "Target")] = target->getCallSign();
    }

    ret[trMark("gm_info", "Faction")] = getLocaleFaction();
    ret[trMark("gm_info", "Lifetime")] = lifetime;
    ret[trMark("gm_info", "Size")] = getMissileSize();

    return ret;
}
