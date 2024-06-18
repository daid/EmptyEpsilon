#ifndef _SPACESHIP_HPP_
#define _SPACESHIP_HPP_

/*TODO Define script conversion function for the EMainScreenSetting enum. 
template<> void convert<MainScreenSetting>::param(lua_State* L, int& idx, MainScreenSetting& mss)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "front")
        mss = MainScreenSetting::Front;
    else if (str == "back")
        mss = MainScreenSetting::Back;
    else if (str == "left")
        mss = MainScreenSetting::Left;
    else if (str == "right")
        mss = MainScreenSetting::Right;
    else if (str == "target")
        mss = MainScreenSetting::Target;
    else if (str == "tactical")
        mss = MainScreenSetting::Tactical;
    else if (str == "longrange")
        mss = MainScreenSetting::LongRange;
    else
        mss = MainScreenSetting::Front;
}

template<> void convert<MainScreenOverlay>::param(lua_State* L, int& idx, MainScreenOverlay& mso)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "hidecomms")
        mso = MainScreenOverlay::HideComms;
    else if (str == "showcomms")
        mso = MainScreenOverlay::ShowComms;
    else
        mso = MainScreenOverlay::HideComms;
}
*/
#endif /* _SPACESHIP_HPP_ */
