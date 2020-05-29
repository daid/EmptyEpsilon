#ifndef _TRACTOR_BEAM_HPP_
#define _TRACTOR_BEAM_HPP_

/* Define script conversion function for the ETractorBeamMode enum. */
template<> void convert<ETractorBeamMode>::param(lua_State* L, int& idx, ETractorBeamMode& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "Off")
        es = TBM_Off;
    else if (str == "Pull")
        es = TBM_Pull;
    else if (str == "Push")
        es = TBM_Push;
    else if (str == "Hold")
        es = TBM_Hold;
    else
        es = TBM_Off;
}

template<> int convert<ETractorBeamMode>::returnType(lua_State* L, ETractorBeamMode es)
{
    switch(es)
    {
    case TBM_Off:
        lua_pushstring(L, "Off");
        return 1;
    case TBM_Pull:
        lua_pushstring(L, "Pull");
        return 1;
    case TBM_Push:
        lua_pushstring(L, "Push");
        return 1;
    case TBM_Hold:
        lua_pushstring(L, "Hold");
        return 1;
    default:
        return 0;
    }
}

#endif /* _TRACTOR_BEAM_HPP_ */
