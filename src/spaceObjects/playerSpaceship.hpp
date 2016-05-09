
#ifndef _PLAYERSPACESHIP_HPP_
#define _PLAYERSPACESHIP_HPP_

template<> int convert<EAlertLevel>::returnType(lua_State* L, EAlertLevel l)
{
    lua_pushstring(L, alertLevelToString(l).c_str());
    return 1;
}

#endif /* _H_PLAYERSPACESHIP_ */
