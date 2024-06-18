#ifndef _PLAYERSPACESHIP_HPP_
#define _PLAYERSPACESHIP_HPP_

/*TODO
template<> int convert<AlertLevel>::returnType(lua_State* L, AlertLevel l)
{
    lua_pushstring(L, alertLevelToString(l).c_str());
    return 1;
}

template<> void convert<AlertLevel>::param(lua_State* L, int& idx, AlertLevel& al)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "normal")
        al = AlertLevel::Normal;
    else if (str == "yellow")
        al = AlertLevel::YellowAlert;
    else if (str == "red")
        al = AlertLevel::RedAlert;
    else
        al = AlertLevel::Normal;
}
*/

#endif /* _H_PLAYERSPACESHIP_ */
