#ifndef _SHIPTEMPLATE_HPP_
#define _SHIPTEMPLATE_HPP_

/* Define script conversion function for the ESystem enum. */
template<> void convert<ShipSystem::Type>::param(lua_State* L, int& idx, ShipSystem::Type& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "reactor")
        es = ShipSystem::Type::Reactor;
    else if (str == "beamweapons")
        es = ShipSystem::Type::BeamWeapons;
    else if (str == "missilesystem")
        es = ShipSystem::Type::MissileSystem;
    else if (str == "maneuver")
        es = ShipSystem::Type::Maneuver;
    else if (str == "impulse")
        es = ShipSystem::Type::Impulse;
    else if (str == "warp")
        es = ShipSystem::Type::Warp;
    else if (str == "jumpdrive")
        es = ShipSystem::Type::JumpDrive;
    else if (str == "frontshield")
        es = ShipSystem::Type::FrontShield;
    else if (str == "rearshield")
        es = ShipSystem::Type::RearShield;
    else
        es = ShipSystem::Type::None;
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
