#ifndef WEAPON_TUBE_H
#define WEAPON_TUBE_H

#include "SFML/System/NonCopyable.hpp"
#include "shipTemplate.h"

enum EWeaponTubeState
{
    WTS_Empty,
    WTS_Loading,
    WTS_Loaded,
    WTS_Unloading
};

class WeaponTube : public sf::NonCopyable
{
public:
    WeaponTube();

    EMissileWeapons type_loaded;
    EWeaponTubeState state;
    float delay;
};

#endif//WEAPON_TUBE_H
