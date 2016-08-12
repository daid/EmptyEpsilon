#include "missileWeaponData.h"

MissileWeaponData missile_data[MW_Count] =
{
    //                speed, turnrate, lifetime, color, homing_range
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(255, 200, 0), 1200.0),/*MW_Homing*/
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(255, 100, 32), 500.0),/*MW_Nuke*/
    MissileWeaponData(100.0f,  0.f, 10.0f, sf::Color(255, 255, 255), 0.0),/*MW_Mine, lifetime is used at time which the mine is ejecting from the ship*/
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(100, 32, 255), 500.0),/*MW_EMP*/
    MissileWeaponData(500.0f,  0.f, 13.5f, sf::Color(200, 200, 200), 0.0),/*MW_HVLI*/
};

MissileWeaponData::MissileWeaponData(float speed, float turnrate, float lifetime, sf::Color color, float homing_range)
: speed(speed), turnrate(turnrate), lifetime(lifetime), color(color), homing_range(homing_range)
{
}

const MissileWeaponData& MissileWeaponData::getDataFor(EMissileWeapons type)
{
    if (type == MW_None)
        return missile_data[0];
    return missile_data[type];
}

#ifndef _MSC_VER
// MFC: GCC does proper external template instantiation, VC++ doesn't.
#include "missileWeaponData.hpp"
#endif
