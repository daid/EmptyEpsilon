#pragma once

#include "../crewPosition.h"
#include "script/enum.h"
#include "script/environment.h"


namespace sp::script {
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