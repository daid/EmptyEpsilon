#ifndef MISSILE_WEAPON_DATA_H
#define MISSILE_WEAPON_DATA_H

#include "multiplayer.h"


enum EMissileWeapons
{
    MW_None = -1,
    MW_Homing = 0,
    MW_Nuke,
    MW_Mine,
    MW_EMP,
    MW_HVLI,
    MW_Count
};

enum EMissileSizes
{
    MS_Small = 0,
    MS_Medium = 1,
    MS_Large = 2,
};
string getMissileSizeString(EMissileSizes size);
string getMissileWeaponName(EMissileWeapons missile);
string getLocaleMissileWeaponName(EMissileWeapons missile);

/* data container for missile weapon data, contains information about different missile weapon types. */
class MissileWeaponData
{
public:
    MissileWeaponData(float speed, float turnrate, float lifetime, glm::u8vec4 color, float homing_range, string fire_sound);

    float speed; //meter/sec
    float turnrate; //deg/sec

    float lifetime; //sec
    glm::u8vec4 color;
    float homing_range;

    string fire_sound;

    static const MissileWeaponData& getDataFor(EMissileWeapons type);

    static float convertSizeToCategoryModifier(EMissileSizes size);
    static EMissileSizes convertCategoryModifierToSize(float size);
};
#endif//MISSILE_WEAPON_DATA_H
