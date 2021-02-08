#ifndef MISSILE_WEAPON_DATA_H
#define MISSILE_WEAPON_DATA_H

#include "engine.h"

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
REGISTER_MULTIPLAYER_ENUM(EMissileSizes);
string getMissileSizeString(EMissileSizes size);

/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es);
template<> int convert<EMissileWeapons>::returnType(lua_State* L, EMissileWeapons es);
/* Define script conversion function for the EMissileSizes enum. */
template <> void convert<EMissileSizes>::param(lua_State* L, int& idx, EMissileSizes& es);
template<> int convert<EMissileSizes>::returnType(lua_State* L, EMissileSizes es);

/* data container for missile weapon data, contains information about different missile weapon types. */
class MissileWeaponData
{
public:
    MissileWeaponData(float speed, float turnrate, float lifetime, sf::Color color, float homing_range, string fire_sound);

    float speed; //meter/sec
    float turnrate; //deg/sec

    float lifetime; //sec
    sf::Color color;
    float homing_range;

    string fire_sound;

    static const MissileWeaponData& getDataFor(EMissileWeapons type);

    static const float convertSizeToCategoryModifier(EMissileSizes size);
    static const EMissileSizes convertCategoryModifierToSize(float size);
};
#endif//MISSILE_WEAPON_DATA_H
