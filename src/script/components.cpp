#include "components.h"
#include "script/environment.h"
#include "script/component.h"
#include "script/callback.h"
#include "components/collision.h"
#include "components/radar.h"
#include "components/rendering.h"
#include "components/spin.h"
#include "components/avoidobject.h"
#include "components/missile.h"
#include "components/name.h"
#include "components/hull.h"
#include "components/shields.h"
#include "components/docking.h"
#include "components/beamweapon.h"
#include "components/reactor.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/missiletubes.h"
#include "components/coolant.h"
#include "components/selfdestruct.h"
#include "components/scanning.h"
#include "components/probe.h"
#include "components/hacking.h"
#include "components/player.h"


#define BIND_MEMBER(T, MEMBER) \
    sp::script::ComponentHandler<T>::members[STRINGIFY(MEMBER)] = { \
        [](lua_State* L, const T& t) { \
            return sp::script::Convert<decltype(t.MEMBER)>::toLua(L, t.MEMBER); \
        }, [](lua_State* L, T& t) { \
            t.MEMBER = sp::script::Convert<decltype(t.MEMBER)>::fromLua(L, -1); \
        } \
    };
#define BIND_MEMBER_NAMED(T, MEMBER, NAME) \
    sp::script::ComponentHandler<T>::members[NAME] = { \
        [](lua_State* L, const T& t) { \
            return sp::script::Convert<decltype(t.MEMBER)>::toLua(L, t.MEMBER); \
        }, [](lua_State* L, T& t) { \
            t.MEMBER = sp::script::Convert<decltype(t.MEMBER)>::fromLua(L, -1); \
        } \
    };
#define BIND_MEMBER_GS(T, NAME, GET, SET) \
    sp::script::ComponentHandler<T>::members[NAME] = { \
        [](lua_State* L, const T& t) { \
            return sp::script::Convert<decltype(std::declval<T>().GET())>::toLua(L, t.GET()); \
        }, [](lua_State* L, T& t) { \
            t.SET(sp::script::Convert<decltype(std::declval<T>().GET())>::fromLua(L, -1)); \
        } \
    };
#define BIND_ARRAY(T, A) \
    sp::script::ComponentHandler<T>::array_count_func = [](const T& t) -> int { return t.A.size(); }; \
    sp::script::ComponentHandler<T>::array_resize_func = [](T& t, int new_size) { t.A.resize(new_size); };
#define BIND_ARRAY_MEMBER(T, A, MEMBER) \
    sp::script::ComponentHandler<T>::indexed_members[STRINGIFY(MEMBER)] = { \
        [](lua_State* L, const T& t, int n) { \
            return sp::script::Convert<decltype(t.A[n].MEMBER)>::toLua(L, t.A[n].MEMBER); \
        }, [](lua_State* L, T& t, int n) { \
            t.A[n].MEMBER = sp::script::Convert<decltype(t.A[n].MEMBER)>::fromLua(L, -1); \
        } \
    };

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
        if (lua_istable(L, idx)) {
            lua_geti(L, idx, 1);
            result.x = lua_tonumber(L, -1);
            lua_pop(L, 1);
            lua_geti(L, idx, 2);
            result.y = lua_tonumber(L, -1);
            lua_pop(L, 1);
        }
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
        if (lua_istable(L, idx)) {
            lua_geti(L, idx, 1);
            result.x = lua_tonumber(L, -1);
            lua_pop(L, 1);
            lua_geti(L, idx, 2);
            result.y = lua_tonumber(L, -1);
            lua_pop(L, 1);
            lua_geti(L, idx, 3);
            result.z = lua_tonumber(L, -1);
            lua_pop(L, 1);
        }
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
        if (lua_istable(L, idx)) {
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
        } else if (lua_isinteger(L, idx)) {
            int n = lua_tointeger(L, idx);
            result.r = float(n & 0xFF) / 255.0f;
            result.g = float((n >> 8) & 0xFF) / 255.0f;
            result.b = float((n >> 16) & 0xFF) / 255.0f;
            result.a = 1.0f;
        }
        return result;
    }
};
template<> struct Convert<DamageType> {
    static int toLua(lua_State* L, DamageType value) {
        switch(value) {
        case DamageType::Energy: lua_pushstring(L, "energy"); break;
        case DamageType::Kinetic: lua_pushstring(L, "kinetic"); break;
        case DamageType::EMP: lua_pushstring(L, "emp"); break;
        }
        return 1;
    }
    static DamageType fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "energy")
            return DamageType::Energy;
        else if (str == "kinetic")
            return DamageType::Kinetic;
        else if (str == "emp")
            return DamageType::EMP;
        luaL_error(L, "Unknown damage type: %s", str.c_str());
        return DamageType::Energy;
    }
};
template<> struct Convert<sp::Physics::Type> {
    static int toLua(lua_State* L, sp::Physics::Type value) {
        switch(value) {
        case sp::Physics::Type::Sensor: lua_pushstring(L, "sensor"); break;
        case sp::Physics::Type::Dynamic: lua_pushstring(L, "dynamic"); break;
        case sp::Physics::Type::Static: lua_pushstring(L, "static"); break;
        }
        return 1;
    }
    static sp::Physics::Type fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "sensor")
            return sp::Physics::Type::Sensor;
        else if (str == "dynamic")
            return sp::Physics::Type::Dynamic;
        else if (str == "static")
            return sp::Physics::Type::Static;
        luaL_error(L, "Unknown physics type: %s", str.c_str());
        return sp::Physics::Type::Sensor;
    }
};
}

void initComponentScriptBindings()
{
    sp::script::ComponentHandler<sp::Transform>::name("transform");
    sp::script::ComponentHandler<sp::Transform>::members["x"] = {
        [](lua_State* L, const sp::Transform& t) {
            return sp::script::Convert<float>::toLua(L, t.getPosition().x);
        }, [](lua_State* L, sp::Transform& t) {
            t.setPosition({sp::script::Convert<float>::fromLua(L, -1), t.getPosition().y});
        }
    };
    sp::script::ComponentHandler<sp::Transform>::members["y"] = {
        [](lua_State* L, const sp::Transform& t) {
            return sp::script::Convert<float>::toLua(L, t.getPosition().y);
        }, [](lua_State* L, sp::Transform& t) {
            t.setPosition({t.getPosition().x, sp::script::Convert<float>::fromLua(L, -1)});
        }
    };
    BIND_MEMBER_GS(sp::Transform, "position", getPosition, setPosition);
    sp::script::ComponentHandler<sp::Transform>::members["rotation"] = {
        [](lua_State* L, const sp::Transform& t) {
            return sp::script::Convert<float>::toLua(L, t.getRotation());
        }, [](lua_State* L, sp::Transform& t) {
            t.setRotation(sp::script::Convert<float>::fromLua(L, -1));
        }
    };
    sp::script::ComponentHandler<sp::Physics>::name("physics");
    BIND_MEMBER_GS(sp::Physics, "type", getType, setType);
    sp::script::ComponentHandler<sp::Physics>::members["size"] = {
        [](lua_State* L, const sp::Physics& p) {
            //TODO: Handle rectangular size
            return sp::script::Convert<float>::toLua(L, p.getSize().x);
        }, [](lua_State* L, sp::Physics& p) {
            p.setCircle(p.getType(), sp::script::Convert<float>::fromLua(L, -1));
        }
    };
    BIND_MEMBER_GS(sp::Physics, "velocity", getVelocity, setVelocity);
    BIND_MEMBER_GS(sp::Physics, "angular_velocity", getAngularVelocity, setAngularVelocity);

    sp::script::ComponentHandler<RadarTrace>::name("radar_trace");
    BIND_MEMBER(RadarTrace, icon);
    BIND_MEMBER(RadarTrace, min_size);
    BIND_MEMBER(RadarTrace, max_size);
    BIND_MEMBER(RadarTrace, radius);
    BIND_MEMBER(RadarTrace, color);
    BIND_MEMBER(RadarTrace, flags);

    sp::script::ComponentHandler<RawRadarSignatureInfo>::name("radar_signature");
    BIND_MEMBER(RawRadarSignatureInfo, gravity);
    BIND_MEMBER(RawRadarSignatureInfo, electrical);
    BIND_MEMBER(RawRadarSignatureInfo, biological);

    sp::script::ComponentHandler<MeshRenderComponent>::name("mesh_render");
    BIND_MEMBER_NAMED(MeshRenderComponent, mesh.name, "mesh");
    BIND_MEMBER_NAMED(MeshRenderComponent, texture.name, "texture");
    BIND_MEMBER_NAMED(MeshRenderComponent, specular_texture.name, "specular_texture");
    BIND_MEMBER_NAMED(MeshRenderComponent, illumination_texture.name, "illumination_texture");
    BIND_MEMBER(MeshRenderComponent, mesh_offset);
    BIND_MEMBER(MeshRenderComponent, scale);

    sp::script::ComponentHandler<Spin>::name("spin");
    BIND_MEMBER(Spin, rate);

    sp::script::ComponentHandler<AvoidObject>::name("avoid_object");
    BIND_MEMBER(AvoidObject, range);

    sp::script::ComponentHandler<ExplodeOnTouch>::name("explode_on_touch");
    BIND_MEMBER(ExplodeOnTouch, damage_at_center);
    BIND_MEMBER(ExplodeOnTouch, damage_at_edge);
    BIND_MEMBER(ExplodeOnTouch, blast_range);
    BIND_MEMBER(ExplodeOnTouch, owner);
    BIND_MEMBER(ExplodeOnTouch, damage_type);
    BIND_MEMBER(ExplodeOnTouch, explosion_sfx);

    sp::script::ComponentHandler<CallSign>::name("callsign");
    BIND_MEMBER(CallSign, callsign);
    sp::script::ComponentHandler<TypeName>::name("typename");
    BIND_MEMBER(TypeName, type_name);

    sp::script::ComponentHandler<LongRangeRadar>::name("long_range_radar");
    BIND_MEMBER(LongRangeRadar, short_range);
    BIND_MEMBER(LongRangeRadar, long_range);
    //TODO: Waypoints, radar_view_linked_entity, callbacks

    sp::script::ComponentHandler<Hull>::name("hull");
    BIND_MEMBER(Hull, current);
    BIND_MEMBER(Hull, max);
    BIND_MEMBER(Hull, allow_destruction);
    BIND_MEMBER(Hull, damaged_by_flags);

    sp::script::ComponentHandler<Shields>::name("shields");
    BIND_MEMBER(Shields, active);
    BIND_MEMBER(Shields, calibration_time);
    BIND_MEMBER(Shields, calibration_delay);
    BIND_MEMBER(Shields, frequency);
    BIND_MEMBER(Shields, energy_use_per_second);
    BIND_ARRAY(Shields, entries);
    BIND_ARRAY_MEMBER(Shields, entries, level);
    BIND_ARRAY_MEMBER(Shields, entries, max);

    sp::script::ComponentHandler<DockingPort>::name("docking_port");
    sp::script::ComponentHandler<DockingBay>::name("docking_bay");
    sp::script::ComponentHandler<BeamWeaponSys>::name("beam_weapons");
    sp::script::ComponentHandler<Reactor>::name("reactor");
    sp::script::ComponentHandler<ImpulseEngine>::name("impulse_engine");
    sp::script::ComponentHandler<ManeuveringThrusters>::name("maneuvering_thrusters");
    sp::script::ComponentHandler<CombatManeuveringThrusters>::name("combat_maneuvering_thrusters");
    sp::script::ComponentHandler<WarpDrive>::name("warp_drive");
    sp::script::ComponentHandler<JumpDrive>::name("jump_drive");
    sp::script::ComponentHandler<MissileTubes>::name("missile_tubes");

    sp::script::ComponentHandler<Coolant>::name("coolant");
    sp::script::ComponentHandler<SelfDestruct>::name("self_destruct");
    sp::script::ComponentHandler<ScienceScanner>::name("science_scanner");
    sp::script::ComponentHandler<ScanProbeLauncher>::name("scan_probe_launcher");
    sp::script::ComponentHandler<HackingDevice>::name("hacking_device");
    sp::script::ComponentHandler<PlayerControl>::name("player_control");
}
