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
/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es);
template<> int convert<EMissileWeapons>::returnType(lua_State* L, EMissileWeapons es);

/* data container for missile weapon data, contains information about different missile weapon types. */
class MissileWeaponData
{
public:
    MissileWeaponData(float speed, float turnrate, float lifetime, sf::Color color, float homing_range);
    
    float speed; //meter/sec
    float turnrate; //deg/sec

    float lifetime; //sec
    sf::Color color;
    float homing_range;
    
    static const MissileWeaponData& getDataFor(EMissileWeapons type);
};

#endif//MISSILE_WEAPON_DATA_H
