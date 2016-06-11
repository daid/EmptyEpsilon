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
    else if (str == "showcomms")
        mss = MSS_ShowComms;
    else if (str == "hidecomms")
        mss = MSS_HideComms;
    else
        mss = MSS_Front;
}

#endif /* _SPACEOBJECTS_HPP_ */
