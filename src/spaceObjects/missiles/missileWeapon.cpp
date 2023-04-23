/*
/// A MissileWeapon is a self-propelled weapon that can be fired from a WeaponTube at either a target SpaceObject or on a trajectory.
/// MissileWeapons that can explode detonate with a blast radius at either the end of its lifetime or upon collision with another collisionable SpaceObject.
/// MissileWeapon-class objects can't be created directly. Use these functions with subclasses derived from MissileWeapon, such as HomingMissile, HVLI, etc.
/// (While also launchable from WeaponTubes, Mines are not MissileWeapons. See the Mine class.)
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(MissileWeapon, SpaceObject)
{
  /// Returns this MissileWeapon owner's SpaceObject.
  /// Example: missile:getOwner()
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getOwner);
  /// Returns this MissileWeapon's target.
  /// Example: missile:getTarget()
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getTarget);
  /// Sets this MissileWeapon's target.
  /// The target must already exist. If it does not, this has no effect.
  /// MissileWeapon:setTarget() does NOT check whether the target can be targeted by a player.
  /// Example: missile:setTarget(enemy)
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, setTarget);
  /// Returns this MissileWeapon's lifetime, in seconds.
  /// Example: missile:getLifetime()
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getLifetime);
  /// Sets this MissileWeapon's lifetime, in seconds.
  /// A missile that can explode does so at the end of its lifetime if it don't hit another collisionable SpaceObject first.
  /// Example: missile:setLifetime(5.0)
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, setLifetime);
  /// Returns this MissileWeapon's size as an EMissileSizes string.
  /// Example: missile:getMissileSize()
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, getMissileSize);
  /// Sets this MissileWeapon's size.
  /// Size modifies a missile's maneuverability, speed, blast radius, lifetime, and damage.
  /// Smaller missiles are weaker, faster, and more nimble. Larger missiles are more powerful, slower, and have a longer lifetime.
  /// Example: missile:setMissileSize("large") -- sets this missile to be large
  REGISTER_SCRIPT_CLASS_FUNCTION(MissileWeapon, setMissileSize);
}

MissileWeapon::MissileWeapon(string multiplayer_name, const MissileWeaponData& data)
: SpaceObject(10, multiplayer_name), data(data)
{
    target_angle = 0;
    category_modifier = 1;
    lifetime = data.lifetime;

    registerMemberReplication(&target);
    registerMemberReplication(&target_angle);
    registerMemberReplication(&category_modifier);

    launch_sound_played = false;
    if (entity) {
        auto hull = entity.addComponent<Hull>();
        hull.max = hull.current = 1;
        hull.damaged_by_flags = (1 << int(DamageType::EMP)) | (1 << int(DamageType::Energy));
    }
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
        soundManager->playSound(data.fire_sound, getPosition(), 400.0, 0.6, (1.0f + random(-0.2f, 0.2f)) * size_speed_modifier);
        launch_sound_played = true;
    }

    // Since we do want the range to remain the same, ensure that slow missiles don't die down as fast.
    lifetime -= delta * size_speed_modifier;
    if (lifetime < 0 && isServer())
    {
        lifeEnded();
        destroy();
    }
    auto physics = entity.getComponent<sp::Physics>();
    if (physics)
        physics->setVelocity(vec2FromAngle(getRotation()) * data.speed * size_speed_modifier);

    if (delta > 0)
    {
        ParticleEngine::spawn(glm::vec3(getPosition().x, getPosition().y, 0), glm::vec3(getPosition().x, getPosition().y, 0), glm::vec3(1, 0.8, 0.8), glm::vec3(0, 0, 0), 5, 20, 5.0);
    }
}

void MissileWeapon::collide(SpaceObject* target, float force)
{
    if (!game_server)
        return;
    if (target->entity == owner)
        return;
    if (!target->entity.hasComponent<Hull>())
        return;

    hitObject(target);
    destroy();
}

void MissileWeapon::updateMovement()
{
    if (data.turnrate > 0.0f)
    {
        if (data.homing_range > 0)
        {
            if (auto tt = target.getComponent<sp::Transform>())
            {
                float r = data.homing_range + 10.0f;
                if (glm::length2(tt->getPosition() - getPosition()) < r*r)
                {
                    target_angle = vec2ToAngle(tt->getPosition() - getPosition());
                }
            }
        }
        // Small missiles have a larger speed & rotational speed, large ones are slower and turn less fast
        float size_speed_modifier = 1 / category_modifier;

        float angle_diff = angleDifference(getRotation(), target_angle);

        auto physics = entity.getComponent<sp::Physics>();
        if (physics) {
            if (angle_diff > 1.0f)
                physics->setAngularVelocity(data.turnrate * size_speed_modifier);
            else if (angle_diff < -1.0f)
                physics->setAngularVelocity(data.turnrate * -1.0f * size_speed_modifier);
            else
                physics->setAngularVelocity(angle_diff * data.turnrate * size_speed_modifier);
        }
    }
}

sp::ecs::Entity MissileWeapon::getOwner()
{
    // Owner is assigned by the weapon tube upon firing.
    if (game_server)
    {
        return owner;
    }

    LOG(ERROR) << "MissileWeapon::getOwner(): owner not replicated to clients.";
    return {};
}

sp::ecs::Entity MissileWeapon::getTarget()
{
    return target;
}

void MissileWeapon::setTarget(sp::ecs::Entity target)
{
    if (!target)
        return;
    this->target = target;
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
        //ret[trMark("gm_info", "Owner")] = owner->getCallSign();
    }

    /*P<SpaceObject> target = game_server->getObjectById(target_id);

    if (target)
    {
        ret[trMark("gm_info", "Target")] = target->getCallSign();
    }

    ret[trMark("gm_info", "Faction")] = getLocaleFaction();
    ret[trMark("gm_info", "Lifetime")] = lifetime;
    ret[trMark("gm_info", "Size")] = getMissileSize();

    return ret;
}
*/