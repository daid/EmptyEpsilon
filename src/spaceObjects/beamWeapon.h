#ifndef BEAM_WEAPON_H
#define BEAM_WEAPON_H

#include "SFML/System/NonCopyable.hpp"
#include "stringImproved.h"

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
};

#endif //BEAM_WEAPON_H