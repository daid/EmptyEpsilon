#ifndef BEAM_WEAPON_H
#define BEAM_WEAPON_H

#include "SFML/System/NonCopyable.hpp"
#include "stringImproved.h"
#include "spaceObjects/spaceObject.h"
class SpaceShip;

class BeamWeapon : public sf::NonCopyable
{
public:
    BeamWeapon();

    void fire(P<SpaceObject> target, ESystem system_target);

    void setParent(SpaceShip* parent);

    void setArc(float arc);
    float getArc();

    void setDirection(float direction);
    float getDirection();

    void setRange(float range);
    float getRange();

    void setTurretArc(float arc);
    float getTurretArc();

    void setTurretDirection(float direction);
    float getTurretDirection();

    void setTurretRotationRate(float rotation_rate);
    float getTurretRotationRate();

    void setCycleTime(float cycle_time);
    float getCycleTime();

    void setDamage(float damage);
    float getDamage();

    float getEnergyPerFire();
    void setEnergyPerFire(float energy);

    float getHeatPerFire();
    void setHeatPerFire(float heat);

    void setPosition(sf::Vector3f position);
    sf::Vector3f getPosition();

    void setBeamTexture(string beam_texture);
    string getBeamTexture();

    float getCooldown();

    void update(float delta);
protected:
    sf::Vector3f position;//Visual position on the 3D model where this beam is fired from.
    SpaceShip* parent; //The ship that this beam weapon is attached to.

    //Beam configuration
    float arc;
    float direction;
    float range;
    float turret_arc;
    float turret_direction;
    float turret_rotation_rate;
    float cycle_time;
    float damage;//Server side only
    float energy_per_beam_fire;//Server side only
    float heat_per_beam_fire;//Server side only
    //Beam runtime state
    float cooldown;
    string beam_texture;
};

#endif//BEAM_WEAPON_H
