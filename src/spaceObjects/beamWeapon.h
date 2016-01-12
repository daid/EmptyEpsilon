#ifndef BEAM_WEAPON_H
#define BEAM_WEAPON_H

#include "SFML/System/NonCopyable.hpp"
#include "stringImproved.h"
#include "spaceObject.h"
class SpaceShip;

class BeamWeapon : public sf::NonCopyable
{
public:
    BeamWeapon();
    //Beam configuration
    float arc;
    float direction;
    float range;
    float cycleTime;
    float damage;//Server side only
    //Beam runtime state
    float cooldown;
    string beam_texture;


    void fire(P<SpaceObject> target, ESystem system_target);

    void setParent(SpaceShip* parent);

    void setPosition(sf::Vector3f position);

    void update(float delta);

protected:
    sf::Vector3f position;
    SpaceShip* parent; //The ship that this beam weapon is attached to.
};

#endif //BEAM_WEAPON_H