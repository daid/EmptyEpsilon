#ifndef GAME_GLOBAL_INFO_HPP
#define GAME_GLOBAL_INFO_HPP

/* Define script conversion function for the EScanningComplexity enum. */
template<> void convert<EScanningComplexity>::param(lua_State* L, int& idx, EScanningComplexity& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "simple")
        es = SC_Simple;
    else if (str == "normal")
        es = SC_Normal;
    else if (str == "advanced")
        es = SC_Advanced;
    else
        es = SC_None;
}

template<> int convert<EScanningComplexity>::returnType(lua_State* L, EScanningComplexity complexity)
{
    switch(complexity)
    {
    case SC_None:
        lua_pushstring(L, "none");
        return 1;
    case SC_Simple:
        lua_pushstring(L, "simple");
        return 1;
    case SC_Normal:
        lua_pushstring(L, "normal");
        return 1;
    case SC_Advanced:
        lua_pushstring(L, "advanced");
        return 1;
    default:
        return 0;
    }
}

/* Define script conversion function for the EHackingGames enum. */
template<> void convert<EHackingGames>::param(lua_State* L, int& idx, EHackingGames& eh)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "mines")
        eh = HG_Mine;
    else if (str == "lights")
        eh = HG_Lights;
    else
        eh = HG_All;
}

template<> int convert<EHackingGames>::returnType(lua_State* L, EHackingGames game)
{
    switch(game)
    {
    case HG_Mine:
        lua_pushstring(L, "mines");
        return 1;
    case HG_Lights:
        lua_pushstring(L, "lights");
        return 1;
    case HG_All:
        lua_pushstring(L, "all");
        return 1;
    default:
        return 0;
    }
}

#endif//GAME_GLOBAL_INFO_HPP
