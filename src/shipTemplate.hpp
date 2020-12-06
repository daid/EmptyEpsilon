#ifndef _SHIPTEMPLATE_HPP_
#define _SHIPTEMPLATE_HPP_

/* Define script conversion function for the ESystem enum. */
template<> void convert<ESystem>::param(lua_State* L, int& idx, ESystem& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "reactor")
        es = SYS_Reactor;
    else if (str == "beamweapons")
        es = SYS_BeamWeapons;
    else if (str == "missilesystem")
        es = SYS_MissileSystem;
    else if (str == "maneuver")
        es = SYS_Maneuver;
    else if (str == "impulse")
        es = SYS_Impulse;
    else if (str == "warp")
        es = SYS_Warp;
    else if (str == "jumpdrive")
        es = SYS_JumpDrive;
    else if (str == "frontshield")
        es = SYS_FrontShield;
    else if (str == "rearshield")
        es = SYS_RearShield;
    else
        es = SYS_None;
}

template<> int convert<ESystem>::returnType(lua_State* L, ESystem es)
{
    switch(es)
    {
    case SYS_Reactor:
        lua_pushstring(L, "reactor");
        return 1;
    case SYS_BeamWeapons:  
        lua_pushstring(L, "beamweapons");
        return 1;
    case SYS_MissileSystem: 
        lua_pushstring(L, "missilesystem");
        return 1;
    case SYS_Maneuver: 
        lua_pushstring(L, "maneuver");
        return 1;
    case SYS_Impulse: 
        lua_pushstring(L, "impulse");
        return 1;
    case SYS_Warp: 
        lua_pushstring(L, "warp");
        return 1;
    case SYS_JumpDrive: 
        lua_pushstring(L, "jumpdrive");
        return 1;
    case SYS_FrontShield: 
        lua_pushstring(L, "frontshield");
        return 1;
    case SYS_RearShield: 
        lua_pushstring(L, "rearshield");
        return 1;
    case SYS_None:  
        lua_pushstring(L, "none");
        return 1;
    default:
        return 0;
    }
}

/* Define script conversion function for the ShipTemplate::TemplateType enum. */
template<> void convert<ShipTemplate::TemplateType>::param(lua_State* L, int& idx, ShipTemplate::TemplateType& tt)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "ship")
        tt = ShipTemplate::Ship;
    else if (str == "playership")
        tt = ShipTemplate::PlayerShip;
    else if (str == "station")
        tt = ShipTemplate::Station;
    else
        tt = ShipTemplate::Ship;
}

#endif /* _SHIPTEMPLATE_HPP_ */
