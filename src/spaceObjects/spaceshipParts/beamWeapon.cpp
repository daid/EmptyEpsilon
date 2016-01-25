#include "beamWeapon.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/beamEffect.h"
#include "spaceObjects/spaceObject.h"

BeamWeapon::BeamWeapon()
{
    arc = 0;
    direction = 0;
    range = 0;
    cycle_time = 6.0;
    cooldown = 0.0;
    damage = 1.0;
    energy_per_beam_fire = 3.0;
    heat_per_beam_fire = 0.02;
    parent = nullptr;
}

void BeamWeapon::setParent(SpaceShip* parent)
{
    assert(!this->parent);
    this->parent = parent;

    parent->registerMemberReplication(&arc);
    parent->registerMemberReplication(&direction);
    parent->registerMemberReplication(&range);
    parent->registerMemberReplication(&cycle_time);
    parent->registerMemberReplication(&cooldown, 0.5);
}

void BeamWeapon::setArc(float arc)
{
    this->arc = arc;
}

float BeamWeapon::getArc()
{
    return arc;
}

void BeamWeapon::setDirection(float direction)
{
    this->direction = direction;
}

float BeamWeapon::getDirection()
{
    return direction;
}

void BeamWeapon::setRange(float range)
{
    this->range = range;
}

float BeamWeapon::getRange()
{
    return range;
}

void BeamWeapon::setCycleTime(float cycle_time)
{
    this->cycle_time = cycle_time;
}

float BeamWeapon::getCycleTime()
{
    return cycle_time;
}

void BeamWeapon::setDamage(float damage)
{
    this->damage = damage;
}

float BeamWeapon::getDamage()
{
    return damage;
}

void BeamWeapon::setPosition(sf::Vector3f position)
{
    this->position = position;
}

sf::Vector3f BeamWeapon::getPosition()
{
    return position;
}

void BeamWeapon::setBeamTexture(string beam_texture)
{
    this->beam_texture = beam_texture;
}

string BeamWeapon::getBeamTexture()
{
    return beam_texture;
}

float BeamWeapon::getCooldown()
{
    return cooldown;
}

void BeamWeapon::update(float delta)
{
    if (cooldown > 0.0)
        cooldown -= delta * parent->getSystemEffectiveness(SYS_BeamWeapons);

    P<SpaceObject> target = parent->getTarget();
    if (game_server && range > 0.0 && target && parent->isEnemy(target) && delta > 0 && parent->current_warp == 0.0 && parent->docking_state == DS_NotDocking) // Only fire beam weapons if we are on the server, have a target, and are not paused.
    {
        if (cooldown <= 0.0)
        {
            sf::Vector2f diff = target->getPosition() - (parent->getPosition() + sf::rotateVector(sf::Vector2f(position.x, position.y), parent->getRotation()));
            float distance = sf::length(diff) - target->getRadius() / 2.0;
            float angle = sf::vector2ToAngle(diff);

            if (distance < range)
            {
                float angleDiff = sf::angleDifference(direction + parent->getRotation(), angle);
                if (abs(angleDiff) < arc / 2.0)
                {
                    if (parent->useEnergy(energy_per_beam_fire))
                    {
                        parent->addHeat(SYS_BeamWeapons, heat_per_beam_fire);
                        fire(target, parent->beam_system_target);
                    }
                }
            }
        }
    }
}

void BeamWeapon::fire(P<SpaceObject> target, ESystem system_target)
{
    //When we fire a beam, and we hit an enemy, check if we are not scanned yet, if we are not, and we hit something that we know is an enemy or friendly,
    //  we now know if this ship is an enemy or friend.
    parent->didAnOffensiveAction();

    cooldown = cycle_time; // Reset time of weapon

    sf::Vector2f hit_location = target->getPosition() - sf::normalize(target->getPosition() - parent->getPosition()) * target->getRadius();
    P<BeamEffect> effect = new BeamEffect();
    effect->setSource(parent, position);
    effect->setTarget(target, hit_location);
    effect->beam_texture = beam_texture;

    DamageInfo info(parent, DT_Energy, hit_location);
    info.frequency = parent->beam_frequency; // Beam weapons now always use frequency of the ship.
    info.system_target = system_target;
    target->takeDamage(damage, info);
}
