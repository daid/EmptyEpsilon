/*TODO
// Define a script conversion function for the DamageInfo structure.
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di)
{
    if (!lua_isstring(L, idx))
        return;
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "energy")
        di.type = DamageType::Energy;
    else if (str == "kinetic")
        di.type = DamageType::Kinetic;
    else if (str == "emp")
        di.type = DamageType::EMP;

    if (!lua_isnumber(L, idx))
        return;

    di.location.x = luaL_checknumber(L, idx++);
    di.location.y = luaL_checknumber(L, idx++);

    if (lua_isnil(L, idx))
        idx++;
    else if (!lua_isnumber(L, idx))
        return;
    else
        di.frequency = luaL_checkinteger(L, idx++);

    if (!lua_isstring(L, idx))
        return;

    convert<ShipSystem::Type>::param(L, idx, di.system_target);
}

template<> void convert<ScanState::State>::param(lua_State* L, int& idx, ScanState::State& ss)
{
    ss = ScanState::State::NotScanned;
    if (!lua_isstring(L, idx))
        return;
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "notscanned" || str == "not")
        ss = ScanState::State::NotScanned;
    else if (str == "friendorfoeidentified")
        ss = ScanState::State::FriendOrFoeIdentified;
    else if (str == "simple" || str == "simplescan")
        ss = ScanState::State::SimpleScan;
    else if (str == "full" || str == "fullscan")
        ss = ScanState::State::FullScan;
}
*/