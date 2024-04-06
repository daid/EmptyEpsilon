#include "missileWeaponData.h"

MissileWeaponData missile_data[MW_Count] =
{
    //                speed, turnrate, lifetime, color, homing_range
    MissileWeaponData(200.0f, 10.f, 27.0f, glm::u8vec4(255, 200, 0, 255), 1200.0, "sfx/rlaunch.wav"),/*MW_Homing*/
    MissileWeaponData(200.0f, 10.f, 27.0f, glm::u8vec4(255, 100, 32, 255), 500.0, "sfx/rlaunch.wav"),/*MW_Nuke*/
    MissileWeaponData(100.0f,  0.f, 10.0f, glm::u8vec4(255, 100, 32, 255), 0.0, "sfx/missile_launch.wav"),/*MW_Mine, lifetime is used at time which the mine is ejecting from the ship*/
    MissileWeaponData(200.0f, 10.f, 27.0f, glm::u8vec4(100, 32, 255, 255), 500.0, "sfx/rlaunch.wav"),/*MW_EMP*/
    MissileWeaponData(500.0f,  0.f, 13.5f, glm::u8vec4(200, 200, 200, 255), 0.0, "sfx/hvli_fire.wav"),/*MW_HVLI*/
};

MissileWeaponData::MissileWeaponData(float speed, float turnrate, float lifetime, glm::u8vec4 color, float homing_range, string fire_sound)
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
            return string("unknown size:") + string(size);
    }
}

float MissileWeaponData::convertSizeToCategoryModifier(EMissileSizes size)
{
    switch(size)
    {
        case MS_Small:
            return 0.5;
        case MS_Medium:
            return 1.0;
        case MS_Large:
            return 2.0;
        default:
            return 1.0;
    }
}

EMissileSizes MissileWeaponData::convertCategoryModifierToSize(float size)
{
    if (std::abs(size - 0.5f) < 0.1f)
        return MS_Small;
    if (std::abs(size - 1.0f) < 0.1f)
        return MS_Medium;
    if (std::abs(size - 2.0f) < 0.1f)
        return MS_Large;
    return MS_Medium;
}

#include "missileWeaponData.hpp"
