#ifndef _SPACEOBJECTS_HPP_
#define _SPACEOBJECTS_HPP_
/* Define script conversion function for the EMainScreenSetting enum. */
template<> void convert<EMainScreenSetting>::param(lua_State* L, int& idx, EMainScreenSetting& mss)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "front")
        mss = MSS_Front;
    else if (str == "back")
        mss = MSS_Back;
    else if (str == "left")
        mss = MSS_Left;
    else if (str == "right")
        mss = MSS_Right;
    else if (str == "tactical")
        mss = MSS_Tactical;
    else if (str == "longrange")
        mss = MSS_LongRange;
    else
        mss = MSS_Front;
}

template<> void convert<EMainScreenOverlay>::param(lua_State* L, int& idx, EMainScreenOverlay& mso)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "hidecomms")
        mso = MSO_HideComms;
    else if (str == "showcomms")
        mso = MSO_ShowComms;
    else
        mso = MSO_HideComms;
}
#endif /* _SPACEOBJECTS_HPP_ */
