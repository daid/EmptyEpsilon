/*TODO
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