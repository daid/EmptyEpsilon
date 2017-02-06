#ifndef _PLAYERSPACESHIP_HPP_
#define _PLAYERSPACESHIP_HPP_

template<> int convert<EAlertLevel>::returnType(lua_State* L, EAlertLevel l)
{
    lua_pushstring(L, alertLevelToString(l).c_str());
    return 1;
}

template<> void convert<EAlertLevel>::param(lua_State* L, int& idx, EAlertLevel& al)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "normal")
        al = AL_Normal;
    else if (str == "yellow")
        al = AL_YellowAlert;
    else if (str == "red")
        al = AL_RedAlert;
    else
        al = AL_Normal;
}

#endif /* _H_PLAYERSPACESHIP_ */
