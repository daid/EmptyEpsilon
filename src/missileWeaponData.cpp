#include "missileWeaponData.h"

/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<EMissileWeapons>::param(lua_State* L, int& idx, EMissileWeapons& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "homing")
        es = MW_Homing;
    else if (str == "nuke")
        es = MW_Nuke;
    else if (str == "mine")
        es = MW_Mine;
    else if (str == "emp")
        es = MW_EMP;
    else if (str == "hvli")
        es = MW_HVLI;
    else
        es = MW_None;
}

template<> int convert<EMissileWeapons>::returnType(lua_State* L, EMissileWeapons es)
{
    switch(es)
    {
    case MW_Homing:
        lua_pushstring(L, "homing");
        return 1;
    case MW_Nuke:
        lua_pushstring(L, "nuke");
        return 1;
    case MW_Mine:
        lua_pushstring(L, "mine");
        return 1;
    case MW_EMP:
        lua_pushstring(L, "emp");
        return 1;
    case MW_HVLI:
        lua_pushstring(L, "hvli");
        return 1;
    default:
        return 0;
    }
}

MissileWeaponData missile_data[MW_Count] =
{
    //                speed, turnrate, lifetime, color, homing_range
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(255, 200, 0), 1200.0),/*MW_Homing*/
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(255, 100, 32), 500.0),/*MW_Nuke*/
    MissileWeaponData(100.0f,  0.f, 10.0f, sf::Color(255, 255, 255), 0.0),/*MW_Mine, lifetime is used at time which the mine is ejecting from the ship*/
    MissileWeaponData(200.0f, 10.f, 27.0f, sf::Color(100, 32, 255), 500.0),/*MW_EMP*/
    MissileWeaponData(400.0f,  0.f, 13.5f, sf::Color(200, 200, 200), 0.0),/*MW_HVLI*/
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
