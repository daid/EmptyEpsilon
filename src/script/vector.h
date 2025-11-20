#pragma once

#include "script/environment.h"
#include <glm/vec2.hpp>
#include <glm/vec3.hpp>
#include <glm/gtc/type_precision.hpp>


namespace sp::script {
template<> struct Convert<glm::vec2> {
    static int toLua(lua_State* L, glm::vec2 value) {
        lua_createtable(L, 3, 0);
        lua_pushnumber(L, value.x);
        lua_rawseti(L, -2, 1);
        lua_pushnumber(L, value.y);
        lua_rawseti(L, -2, 2);
        return 1;
    }
    static glm::vec2 fromLua(lua_State* L, int idx) {
        glm::vec2 result{};
        luaL_checktype(L, idx, LUA_TTABLE);
        lua_geti(L, idx, 1);
        result.x = lua_tonumber(L, -1);
        lua_pop(L, 1);
        lua_geti(L, idx, 2);
        result.y = lua_tonumber(L, -1);
        lua_pop(L, 1);
        return result;
    }
};
template<> struct Convert<glm::vec3> {
    static int toLua(lua_State* L, glm::vec3 value) {
        lua_createtable(L, 3, 0);
        lua_pushnumber(L, value.x);
        lua_rawseti(L, -2, 1);
        lua_pushnumber(L, value.y);
        lua_rawseti(L, -2, 2);
        lua_pushnumber(L, value.z);
        lua_rawseti(L, -2, 3);
        return 1;
    }
    static glm::vec3 fromLua(lua_State* L, int idx) {
        glm::vec3 result{};
        luaL_checktype(L, idx, LUA_TTABLE);
        lua_geti(L, idx, 1);
        result.x = lua_tonumber(L, -1);
        lua_pop(L, 1);
        lua_geti(L, idx, 2);
        result.y = lua_tonumber(L, -1);
        lua_pop(L, 1);
        lua_geti(L, idx, 3);
        result.z = lua_tonumber(L, -1);
        lua_pop(L, 1);
        return result;
    }
};
template<> struct Convert<glm::u8vec4> {
    static int toLua(lua_State* L, glm::u8vec4 value) {
        lua_createtable(L, 4, 0);
        lua_pushnumber(L, value.r);
        lua_rawseti(L, -2, 1);
        lua_pushnumber(L, value.g);
        lua_rawseti(L, -2, 2);
        lua_pushnumber(L, value.b);
        lua_rawseti(L, -2, 3);
        lua_pushnumber(L, value.a);
        lua_rawseti(L, -2, 4);
        return 1;
    }
    static glm::u8vec4 fromLua(lua_State* L, int idx) {
        glm::u8vec4 result{};
        if (lua_isstring(L, idx)) {
            result = glm::u8vec4(255,255,255,255);
            string str = string(lua_tostring(L, idx)).lower();
            if (str == "black") { result = glm::u8vec4(0,0,0,255); return result; }
            else if (str == "white") { result = glm::u8vec4(255,255,255,255); return result; }
            else if (str == "red") { result = glm::u8vec4(255,0,0,255); return result; }
            else if (str == "green") { result = glm::u8vec4(0,255,0,255); return result; }
            else if (str == "blue") { result = glm::u8vec4(0,0,255,255); return result; }
            else if (str == "yellow") { result = glm::u8vec4(255,255,0,255); return result; }
            else if (str == "magenta") { result = glm::u8vec4(255,0,255,255); return result; }
            else if (str == "cyan") { result = glm::u8vec4(0,255,255,255); return result; }

            if (str.startswith("#") && str.length() == 7)
            {
                result.r = static_cast<uint8_t>(str.substr(1, 3).toInt(16));
                result.g = static_cast<uint8_t>(str.substr(3, 5).toInt(16));
                result.b = static_cast<uint8_t>(str.substr(5, 7).toInt(16));
            }
            else
            {
                std::vector<string> parts = str.split(",");
                if (parts.size() == 3)
                {
                    result.r = static_cast<uint8_t>(parts[0].toInt());
                    result.g = static_cast<uint8_t>(parts[1].toInt());
                    result.b = static_cast<uint8_t>(parts[2].toInt());
                }
            }
        } else if (lua_isinteger(L, idx)) {
            int n = lua_tointeger(L, idx);
            result.r = float(n & 0xFF) / 255.0f;
            result.g = float((n >> 8) & 0xFF) / 255.0f;
            result.b = float((n >> 16) & 0xFF) / 255.0f;
            result.a = 1.0f;
        } else {
            luaL_checktype(L, idx, LUA_TTABLE);
            lua_geti(L, idx, 1);
            result.r = lua_tonumber(L, -1);
            lua_pop(L, 1);
            lua_geti(L, idx, 2);
            result.g = lua_tonumber(L, -1);
            lua_pop(L, 1);
            lua_geti(L, idx, 3);
            result.b = lua_tonumber(L, -1);
            lua_pop(L, 1);
            lua_geti(L, idx, 4);
            result.a = lua_tonumber(L, -1);
            lua_pop(L, 1);
        }
        return result;
    }
};
template<> struct Convert<glm::ivec2> {
    static int toLua(lua_State* L, glm::ivec2 value) {
        lua_createtable(L, 3, 0);
        lua_pushinteger(L, value.x);
        lua_rawseti(L, -2, 1);
        lua_pushinteger(L, value.y);
        lua_rawseti(L, -2, 2);
        return 1;
    }
    static glm::ivec2 fromLua(lua_State* L, int idx) {
        glm::ivec2 result{};
        luaL_checktype(L, idx, LUA_TTABLE);
        lua_geti(L, idx, 1);
        result.x = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_geti(L, idx, 2);
        result.y = lua_tointeger(L, -1);
        lua_pop(L, 1);
        return result;
    }
};
}
