#pragma once

#include "systems/damage.h"
#include "script/enum.h"
#include "script/environment.h"


namespace sp::script {
template<> struct Convert<DamageInfo> {
    static int toLua(lua_State* L, const DamageInfo& value) {
        lua_newtable(L);
        Convert<sp::ecs::Entity>::toLua(L, value.instigator);
        lua_setfield(L, -2, "instigator");
        Convert<DamageType>::toLua(L, value.type);
        lua_setfield(L, -2, "type");
        Convert<float>::toLua(L, value.location.x);
        lua_setfield(L, -2, "x");
        Convert<float>::toLua(L, value.location.y);
        lua_setfield(L, -2, "y");
        Convert<int>::toLua(L, value.frequency);
        lua_setfield(L, -2, "frequency");
        Convert<ShipSystem::Type>::toLua(L, value.system_target);
        lua_setfield(L, -2, "system_target");
        return 1;
    }
    static DamageInfo fromLua(lua_State* L, int idx) {
        DamageInfo result;
        if (lua_istable(L, idx)) {
            if (lua_getfield(L, idx, "instigator") != LUA_TNIL)
                result.instigator = Convert<sp::ecs::Entity>::fromLua(L, -1);
            lua_pop(L, 1);
            if (lua_getfield(L, idx, "type") != LUA_TNIL)
                result.type = Convert<DamageType>::fromLua(L, -1);
            lua_pop(L, 1);
            if (lua_getfield(L, idx, "x") != LUA_TNIL)
                result.location.x = Convert<float>::fromLua(L, -1);
            lua_pop(L, 1);
            if (lua_getfield(L, idx, "y") != LUA_TNIL)
                result.location.y = Convert<float>::fromLua(L, -1);
            lua_pop(L, 1);
            if (lua_getfield(L, idx, "frequency") != LUA_TNIL)
                result.frequency = Convert<int>::fromLua(L, -1);
            lua_pop(L, 1);
            if (lua_getfield(L, idx, "system_target") != LUA_TNIL)
                result.system_target = Convert<ShipSystem::Type>::fromLua(L, -1);
            lua_pop(L, 1);
        }
        return result;
    }
};
}