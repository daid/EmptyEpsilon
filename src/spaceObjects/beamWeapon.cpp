#include "beamWeapon.h"
#include "spaceship.h"
#include "beamEffect.h"
#include "spaceObjects/spaceObject.h"
#include "shipTemplate.h" //For SYS_BeamWeapons

BeamWeapon::BeamWeapon()
{
    arc = 0;
    direction = 0;
    range = 0;
    cycleTime = 6.0;
    cooldown = 0.0;
    damage = 1.0;
    parent = nullptr;
}

void BeamWeapon::setParent(SpaceShip* parent)
{
    this->parent = parent;
}

void BeamWeapon::setPosition(sf::Vector3f position)
{
    this->position = position;
}

void BeamWeapon::fire(P<SpaceObject> target, ESystem system_target)
{
    cooldown = cycleTime; // Reset time of weapon

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

void BeamWeapon::update(float delta)
{
    if(cooldown > 0.0)
    {
        cooldown -= delta * parent->getSystemEffectiveness(SYS_BeamWeapons);
    }
}


