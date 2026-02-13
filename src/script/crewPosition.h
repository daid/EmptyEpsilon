#pragma once

#include "../crewPosition.h"
#include "script/environment.h"

namespace sp::script {
template<> struct Convert<CrewPosition> {
    static int toLua(lua_State* L, CrewPosition value) {
        lua_pushstring(L, crewPositionToString(value).c_str());
        return 1;
    }
    static CrewPosition fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();

        auto result = tryParseCrewPosition(str);
        if (!result.has_value()) {
            luaL_error(L, "Unknown CrewPosition: %s", str.c_str());
        }
        return result.value_or(CrewPosition::helmsOfficer);
    }
};

template<> struct Convert<CrewPositions> {
    static int toLua(lua_State* L, CrewPositions value) {
        lua_newtable(L);
        int idx = 1;
        for(auto cp : value) {
            Convert<CrewPosition>::toLua(L, cp);
            lua_rawseti(L, -2, idx++);
        }
        return 1;
    }
    static CrewPositions fromLua(lua_State* L, int idx) {
        CrewPositions result;
        if (lua_istable(L, idx)) {
            int table_index = 1;
            while(true) {
                lua_rawgeti(L, idx, table_index++);
                if (lua_isnil(L, -1)) {
                    lua_pop(L, 1);
                    break;
                }
                result.add(Convert<CrewPosition>::fromLua(L, -1));
                lua_pop(L, 1);
            }
        } else {
            result.add(Convert<CrewPosition>::fromLua(L, idx));
        }
        return result;
    }
};
}