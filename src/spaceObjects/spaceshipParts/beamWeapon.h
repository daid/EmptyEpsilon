#ifndef BEAM_WEAPON_H
#define BEAM_WEAPON_H

#include "stringImproved.h"
#include "spaceObjects/spaceObject.h"

class SpaceShip;

class BeamWeapon : sp::NonCopyable
{
public:
    BeamWeapon();

    void fire(P<SpaceObject> target, ESystem system_target);

    void setParent(SpaceShip* parent);

    void setArc(float arc);
    float getArc();

    void setArcColor(glm::u8vec4 color);
    glm::u8vec4 getArcColor();

    void setArcFireColor(glm::u8vec4 color);
    glm::u8vec4 getArcFireColor();

    void setDamageType(EDamageType type);
    EDamageType getDamageType();

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

    void setPosition(glm::vec3 position);
    glm::vec3 getPosition();

    void setBeamTexture(string beam_texture);
    string getBeamTexture();

    float getCooldown();

    void update(float delta);
protected:
    glm::vec3 position;//Visual position on the 3D model where this beam is fired from.
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
    glm::u8vec4 arc_color;
    glm::u8vec4 arc_color_fire;
    EDamageType damage_type;
    //Beam runtime state
    float cooldown;
    string beam_texture;
};

#endif//BEAM_WEAPON_H
