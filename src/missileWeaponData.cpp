#include "missileWeaponData.h"

MissileWeaponData missile_data[MW_Count] =
{
    //                speed, turnrate, lifetime, color, homing_range
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(255, 200, 0), 1200.0, "sfx/rlaunch.wav"),/*MW_Homing*/
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(255, 100, 32), 500.0, "sfx/rlaunch.wav"),/*MW_Nuke*/
    MissileWeaponData(100.0f,  0.f, 10.0f, sf::Color(255, 255, 255), 0.0, "missile_launch.wav"),/*MW_Mine, lifetime is used at time which the mine is ejecting from the ship*/
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(100, 32, 255), 500.0, "sfx/rlaunch.wav"),/*MW_EMP*/
    MissileWeaponData(500.0f,  0.f, 13.5f, sf::Color(200, 200, 200), 0.0, "sfx/hvli_fire.wav"),/*MW_HVLI*/
};

MissileWeaponData::MissileWeaponData(float speed, float turnrate, float lifetime, sf::Color color, float homing_range, string fire_sound)
: speed(speed), turnrate(turnrate), lifetime(lifetime), color(color), homing_range(homing_range), fire_sound(fire_sound)
{
}

const MissileWeaponData& MissileWeaponData::getDataFor(EMissileWeapons type)
{
    if (type == MW_None)
        return missile_data[0];
    return missile_data[type];
}

string getMissileSizeString(EMissileSizes size)
{
    switch (size)
    {
        case MS_Small:
            return "small";
        case MS_Medium:
            return "medium";
        case MS_Large:
            return "large";
        default:
            return "unknown size:" + size;
    }
}

#include "missileWeaponData.hpp"
