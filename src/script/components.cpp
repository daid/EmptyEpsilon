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
#include "components/faction.h"
#include "components/ai.h"
#include "ai/ai.h"
#include "components/radarblock.h"
#include "components/gravity.h"

#define STRINGIFY(n) #n
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
            return sp::script::Convert<std::remove_cv_t<std::remove_reference_t<decltype(t.MEMBER)>>>::toLua(L, t.MEMBER); \
        }, [](lua_State* L, T& t) { \
            t.MEMBER = sp::script::Convert<std::remove_cv_t<std::remove_reference_t<decltype(t.MEMBER)>>>::fromLua(L, -1); \
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
#define BIND_MEMBER_FLAG(T, MEMBER, NAME, MASK) \
    sp::script::ComponentHandler<T>::members[NAME] = { \
        [](lua_State* L, const T& t) { \
            return sp::script::Convert<bool>::toLua(L, ((t.MEMBER) & (MASK)) == (MASK) ); \
        }, [](lua_State* L, T& t) { \
            auto result = (t.MEMBER) & ~(MASK); \
            if (sp::script::Convert<bool>::fromLua(L, -1)) result |= (MASK); \
            t.MEMBER = result; \
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
#define BIND_ARRAY_MEMBER_NAMED(T, A, NAME, MEMBER) \
    sp::script::ComponentHandler<T>::indexed_members[NAME] = { \
        [](lua_State* L, const T& t, int n) { \
            return sp::script::Convert<decltype(t.A[n].MEMBER)>::toLua(L, t.A[n].MEMBER); \
        }, [](lua_State* L, T& t, int n) { \
            t.A[n].MEMBER = sp::script::Convert<decltype(t.A[n].MEMBER)>::fromLua(L, -1); \
        } \
    };
#define BIND_SHIP_SYSTEM(T) \
    BIND_MEMBER(T, health); \
    BIND_MEMBER(T, health_max); \
    BIND_MEMBER(T, power_level); \
    BIND_MEMBER(T, power_request); \
    BIND_MEMBER(T, heat_level); \
    BIND_MEMBER(T, coolant_level); \
    BIND_MEMBER(T, coolant_request); \
    BIND_MEMBER(T, can_be_hacked); \
    BIND_MEMBER(T, hacked_level); \
    BIND_MEMBER(T, power_factor); \
    BIND_MEMBER(T, coolant_change_rate_per_second); \
    BIND_MEMBER(T, heat_add_rate_per_second); \
    BIND_MEMBER(T, power_change_rate_per_second); \
    BIND_MEMBER(T, auto_repair_per_second);


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
template<> struct Convert<FactionRelation> {
    static int toLua(lua_State* L, FactionRelation value) {
        switch(value) {
        case FactionRelation::Friendly: lua_pushstring(L, "friendly"); break;
        case FactionRelation::Neutral: lua_pushstring(L, "neutral"); break;
        case FactionRelation::Enemy: lua_pushstring(L, "enemy"); break;
        }
        return 1;
    }
    static FactionRelation fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "friendly")
            return FactionRelation::Friendly;
        else if (str == "neutral")
            return FactionRelation::Neutral;
        else if (str == "enemy")
            return FactionRelation::Enemy;
        luaL_error(L, "Unknown relation type: %s", str.c_str());
        return FactionRelation::Neutral;
    }
};
template<> struct Convert<AIOrder> {
    static int toLua(lua_State* L, AIOrder value) {
        switch(value) {
        case AIOrder::Idle: lua_pushstring(L, "idle"); break;
        case AIOrder::Roaming: lua_pushstring(L, "roaming"); break;
        case AIOrder::Retreat: lua_pushstring(L, "retreat"); break;
        case AIOrder::StandGround: lua_pushstring(L, "standground"); break;
        case AIOrder::DefendLocation: lua_pushstring(L, "defendlocation"); break;
        case AIOrder::DefendTarget: lua_pushstring(L, "defendtarget"); break;
        case AIOrder::FlyFormation: lua_pushstring(L, "flyformation"); break;
        case AIOrder::FlyTowards: lua_pushstring(L, "flytowards"); break;
        case AIOrder::FlyTowardsBlind: lua_pushstring(L, "flytowardsblind"); break;
        case AIOrder::Dock: lua_pushstring(L, "dock"); break;
        case AIOrder::Attack: lua_pushstring(L, "attack"); break;
        }
        return 1;
    }
    static AIOrder fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "idle")
            return AIOrder::Idle;
        else if (str == "roaming")
            return AIOrder::Roaming;
        else if (str == "retreat")
            return AIOrder::Retreat;
        else if (str == "standground")
            return AIOrder::StandGround;
        else if (str == "defendlocation")
            return AIOrder::DefendLocation;
        else if (str == "defendtarget")
            return AIOrder::DefendTarget;
        else if (str == "flyformation")
            return AIOrder::FlyFormation;
        else if (str == "flytowards")
            return AIOrder::FlyTowards;
        else if (str == "flytowardsblind")
            return AIOrder::FlyTowardsBlind;
        else if (str == "dock")
            return AIOrder::Dock;
        else if (str == "attack")
            return AIOrder::Attack;
        luaL_error(L, "Unknown AIOrder type: %s", str.c_str());
        return AIOrder::Idle;
    }
};
template<> struct Convert<EMissileWeapons> {
    static int toLua(lua_State* L, EMissileWeapons value) {
        switch(value) {
        case EMissileWeapons::MW_None: lua_pushstring(L, "none"); break;
        case EMissileWeapons::MW_Homing: lua_pushstring(L, "homing"); break;
        case EMissileWeapons::MW_Nuke: lua_pushstring(L, "nuke"); break;
        case EMissileWeapons::MW_Mine: lua_pushstring(L, "mine"); break;
        case EMissileWeapons::MW_EMP: lua_pushstring(L, "emp"); break;
        case EMissileWeapons::MW_HVLI: lua_pushstring(L, "hvli"); break;
        case EMissileWeapons::MW_Count: lua_pushstring(L, "none"); break;
        }
        return 1;
    }
    static EMissileWeapons fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "none")
            return EMissileWeapons::MW_None;
        else if (str == "homing")
            return EMissileWeapons::MW_Homing;
        else if (str == "nuke")
            return EMissileWeapons::MW_Nuke;
        else if (str == "mine")
            return EMissileWeapons::MW_Mine;
        else if (str == "emp")
            return EMissileWeapons::MW_EMP;
        else if (str == "hvli")
            return EMissileWeapons::MW_HVLI;
        luaL_error(L, "Unknown EMissileWeapons type: %s", str.c_str());
        return EMissileWeapons::MW_None;
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
            if (p.getShape() == sp::Physics::Shape::Rectangle)
                return sp::script::Convert<glm::vec2>::toLua(L, p.getSize());
            return sp::script::Convert<float>::toLua(L, p.getSize().x);
        }, [](lua_State* L, sp::Physics& p) {
            if (lua_istable(L, -1))
                p.setRectangle(p.getType(), sp::script::Convert<glm::vec2>::fromLua(L, -1));
            else
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
    BIND_MEMBER_FLAG(RadarTrace, flags, "rotate", RadarTrace::Rotate);
    BIND_MEMBER_FLAG(RadarTrace, flags, "color_by_faction", RadarTrace::ColorByFaction);
    BIND_MEMBER_FLAG(RadarTrace, flags, "arrow_if_not_scanned", RadarTrace::ArrowIfNotScanned);
    BIND_MEMBER_FLAG(RadarTrace, flags, "blend_add", RadarTrace::BlendAdd);
    BIND_MEMBER_FLAG(RadarTrace, flags, "long_range", RadarTrace::LongRange);

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

    sp::script::ComponentHandler<DelayedExplodeOnTouch>::name("delayed_explode_on_touch");
    BIND_MEMBER(DelayedExplodeOnTouch, delay);
    BIND_MEMBER(DelayedExplodeOnTouch, triggered);
    BIND_MEMBER(DelayedExplodeOnTouch, damage_at_center);
    BIND_MEMBER(DelayedExplodeOnTouch, damage_at_edge);
    BIND_MEMBER(DelayedExplodeOnTouch, blast_range);
    BIND_MEMBER(DelayedExplodeOnTouch, owner);
    BIND_MEMBER(DelayedExplodeOnTouch, damage_type);
    BIND_MEMBER(DelayedExplodeOnTouch, explosion_sfx);

    sp::script::ComponentHandler<CallSign>::name("callsign");
    BIND_MEMBER(CallSign, callsign);
    sp::script::ComponentHandler<TypeName>::name("typename");
    BIND_MEMBER(TypeName, type_name);
    BIND_MEMBER(TypeName, localized);

    sp::script::ComponentHandler<LongRangeRadar>::name("long_range_radar");
    BIND_MEMBER(LongRangeRadar, short_range);
    BIND_MEMBER(LongRangeRadar, long_range);
    BIND_MEMBER(LongRangeRadar, radar_view_linked_entity);
    BIND_ARRAY(LongRangeRadar, waypoints);
    BIND_ARRAY_MEMBER(LongRangeRadar, waypoints, x);
    BIND_ARRAY_MEMBER(LongRangeRadar, waypoints, y);
    //TODO: callbacks for probes

    sp::script::ComponentHandler<Hull>::name("hull");
    BIND_MEMBER(Hull, current);
    BIND_MEMBER(Hull, max);
    BIND_MEMBER(Hull, allow_destruction);
    BIND_MEMBER_FLAG(Hull, damaged_by_flags, "damaged_by_energy", (1 << int(DamageType::Energy)));
    BIND_MEMBER_FLAG(Hull, damaged_by_flags, "damaged_by_kinetic", (1 << int(DamageType::Kinetic)));
    BIND_MEMBER_FLAG(Hull, damaged_by_flags, "damaged_by_emp", (1 << int(DamageType::EMP)));

    sp::script::ComponentHandler<Shields>::name("shields");
    BIND_MEMBER_NAMED(Shields, front_system.health, "front_health");
    BIND_MEMBER_NAMED(Shields, front_system.health_max, "front_health_max");
    BIND_MEMBER_NAMED(Shields, front_system.power_level, "front_power_level");
    BIND_MEMBER_NAMED(Shields, front_system.power_request, "front_power_request");
    BIND_MEMBER_NAMED(Shields, front_system.heat_level, "front_heat_level");
    BIND_MEMBER_NAMED(Shields, front_system.coolant_level, "front_coolant_level");
    BIND_MEMBER_NAMED(Shields, front_system.coolant_request, "front_coolant_request");
    BIND_MEMBER_NAMED(Shields, front_system.can_be_hacked, "front_can_be_hacked");
    BIND_MEMBER_NAMED(Shields, front_system.hacked_level, "front_hacked_level");
    BIND_MEMBER_NAMED(Shields, front_system.power_factor, "front_power_factor");
    BIND_MEMBER_NAMED(Shields, front_system.coolant_change_rate_per_second, "front_coolant_change_rate_per_second");
    BIND_MEMBER_NAMED(Shields, front_system.heat_add_rate_per_second, "front_heat_add_rate_per_second");
    BIND_MEMBER_NAMED(Shields, front_system.power_change_rate_per_second, "front_power_change_rate_per_second");
    BIND_MEMBER_NAMED(Shields, front_system.auto_repair_per_second, "front_auto_repair_per_second");
    BIND_MEMBER_NAMED(Shields, rear_system.health, "rear_health");
    BIND_MEMBER_NAMED(Shields, rear_system.health_max, "rear_health_max");
    BIND_MEMBER_NAMED(Shields, rear_system.power_level, "rear_power_level");
    BIND_MEMBER_NAMED(Shields, rear_system.power_request, "rear_power_request");
    BIND_MEMBER_NAMED(Shields, rear_system.heat_level, "rear_heat_level");
    BIND_MEMBER_NAMED(Shields, rear_system.coolant_level, "rear_coolant_level");
    BIND_MEMBER_NAMED(Shields, rear_system.coolant_request, "rear_coolant_request");
    BIND_MEMBER_NAMED(Shields, rear_system.can_be_hacked, "rear_can_be_hacked");
    BIND_MEMBER_NAMED(Shields, rear_system.hacked_level, "rear_hacked_level");
    BIND_MEMBER_NAMED(Shields, rear_system.power_factor, "rear_power_factor");
    BIND_MEMBER_NAMED(Shields, rear_system.coolant_change_rate_per_second, "rear_coolant_change_rate_per_second");
    BIND_MEMBER_NAMED(Shields, rear_system.heat_add_rate_per_second, "rear_heat_add_rate_per_second");
    BIND_MEMBER_NAMED(Shields, rear_system.power_change_rate_per_second, "rear_power_change_rate_per_second");
    BIND_MEMBER_NAMED(Shields, rear_system.auto_repair_per_second, "rear_auto_repair_per_second");

    BIND_MEMBER(Shields, active);
    BIND_MEMBER(Shields, calibration_time);
    BIND_MEMBER(Shields, calibration_delay);
    BIND_MEMBER(Shields, frequency);
    BIND_MEMBER(Shields, energy_use_per_second);
    BIND_ARRAY(Shields, entries);
    BIND_ARRAY_MEMBER(Shields, entries, level);
    BIND_ARRAY_MEMBER(Shields, entries, max);

    sp::script::ComponentHandler<DockingPort>::name("docking_port");
    BIND_MEMBER(DockingPort, dock_class);
    BIND_MEMBER(DockingPort, dock_subclass);
    //TODO: BIND_MEMBER(DockingPort, state);
    BIND_MEMBER(DockingPort, target);
    BIND_MEMBER(DockingPort, auto_reload_missiles);

    sp::script::ComponentHandler<DockingBay>::name("docking_bay");
    BIND_MEMBER_FLAG(DockingBay, flags, "share_energy", DockingBay::ShareEnergy);
    BIND_MEMBER_FLAG(DockingBay, flags, "repair", DockingBay::Repair);
    BIND_MEMBER_FLAG(DockingBay, flags, "charge_shields", DockingBay::ChargeShield);
    BIND_MEMBER_FLAG(DockingBay, flags, "restock_probes", DockingBay::RestockProbes);
    BIND_MEMBER_FLAG(DockingBay, flags, "restock_missiles", DockingBay::RestockMissiles);

    sp::script::ComponentHandler<BeamWeaponSys>::name("beam_weapons");
    BIND_SHIP_SYSTEM(BeamWeaponSys);
    BIND_MEMBER(BeamWeaponSys, frequency);
    //TODO: BIND_MEMBER(BeamWeaponSys, system_target);
    BIND_ARRAY(BeamWeaponSys, mounts);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, arc);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, direction);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, range);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, turret_arc);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, turret_direction);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, turret_rotation_rate);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, cycle_time);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, damage);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, energy_per_beam_fire);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, heat_per_beam_fire);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, arc_color);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, arc_color_fire);
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, damage_type);
    //TODO: BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, texture);

    sp::script::ComponentHandler<Reactor>::name("reactor");
    BIND_SHIP_SYSTEM(Reactor);
    BIND_MEMBER(Reactor, max_energy);
    BIND_MEMBER(Reactor, energy);

    sp::script::ComponentHandler<ImpulseEngine>::name("impulse_engine");
    BIND_SHIP_SYSTEM(ImpulseEngine);
    BIND_MEMBER(ImpulseEngine, max_speed_forward);
    BIND_MEMBER(ImpulseEngine, max_speed_reverse);
    BIND_MEMBER(ImpulseEngine, acceleration_forward);
    BIND_MEMBER(ImpulseEngine, acceleration_reverse);
    BIND_MEMBER(ImpulseEngine, sound);
    BIND_MEMBER(ImpulseEngine, request);
    BIND_MEMBER(ImpulseEngine, actual);
    sp::script::ComponentHandler<ManeuveringThrusters>::name("maneuvering_thrusters");
    BIND_SHIP_SYSTEM(ManeuveringThrusters);
    BIND_MEMBER(ManeuveringThrusters, speed);
    BIND_MEMBER(ManeuveringThrusters, target);
    BIND_MEMBER(ManeuveringThrusters, rotation_request);
    sp::script::ComponentHandler<CombatManeuveringThrusters>::name("combat_maneuvering_thrusters");
    BIND_MEMBER(CombatManeuveringThrusters, charge);
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.speed, "boost_speed");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.speed, "strafe_speed");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.request, "boost_request");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.request, "strafe_request");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.active, "boost_active");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.active, "strafe_active");
    sp::script::ComponentHandler<WarpDrive>::name("warp_drive");
    BIND_SHIP_SYSTEM(WarpDrive);
    BIND_MEMBER(WarpDrive, max_level);
    BIND_MEMBER(WarpDrive, speed_per_level);
    BIND_MEMBER(WarpDrive, energy_warp_per_second);
    BIND_MEMBER(WarpDrive, request);
    BIND_MEMBER(WarpDrive, current);
    sp::script::ComponentHandler<JumpDrive>::name("jump_drive");
    BIND_SHIP_SYSTEM(JumpDrive);
    BIND_MEMBER(JumpDrive, min_distance);
    BIND_MEMBER(JumpDrive, max_distance);
    BIND_MEMBER(JumpDrive, charge);
    BIND_MEMBER(JumpDrive, distance);
    BIND_MEMBER(JumpDrive, delay);
    
    sp::script::ComponentHandler<MissileTubes>::name("missile_tubes");
    BIND_SHIP_SYSTEM(MissileTubes);
    BIND_MEMBER_NAMED(MissileTubes, storage[int(MW_Homing)], "storage_homing");
    BIND_MEMBER_NAMED(MissileTubes, storage_max[int(MW_Homing)], "max_homing");
    BIND_MEMBER_NAMED(MissileTubes, storage[int(MW_Nuke)], "storage_nuke");
    BIND_MEMBER_NAMED(MissileTubes, storage_max[int(MW_Nuke)], "max_nuke");
    BIND_MEMBER_NAMED(MissileTubes, storage[int(MW_Mine)], "storage_mine");
    BIND_MEMBER_NAMED(MissileTubes, storage_max[int(MW_Mine)], "max_mine");
    BIND_MEMBER_NAMED(MissileTubes, storage[int(MW_EMP)], "storage_emp");
    BIND_MEMBER_NAMED(MissileTubes, storage_max[int(MW_EMP)], "max_emp");
    BIND_MEMBER_NAMED(MissileTubes, storage[int(MW_HVLI)], "storage_hvli");
    BIND_MEMBER_NAMED(MissileTubes, storage_max[int(MW_HVLI)], "max_hvli");
    BIND_ARRAY(MissileTubes, mounts);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, position);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, load_time);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, type_allowed_mask);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, direction);
    //TODO: BIND_ARRAY_MEMBER(MissileTubes, mounts, size);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, type_loaded);
    //TODO: BIND_ARRAY_MEMBER(MissileTubes, mounts, state);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, delay);

    sp::script::ComponentHandler<Coolant>::name("coolant");
    BIND_MEMBER(Coolant, max);
    BIND_MEMBER(Coolant, max_coolant_per_system);
    BIND_MEMBER(Coolant, auto_levels);

    sp::script::ComponentHandler<SelfDestruct>::name("self_destruct");
    BIND_MEMBER(SelfDestruct, active);
    BIND_MEMBER(SelfDestruct, countdown);
    BIND_MEMBER(SelfDestruct, damage);
    BIND_MEMBER(SelfDestruct, size);
    sp::script::ComponentHandler<ScienceScanner>::name("science_scanner");
    BIND_MEMBER(ScienceScanner, delay);
    BIND_MEMBER(ScienceScanner, max_scanning_delay);
    BIND_MEMBER(ScienceScanner, target);
    sp::script::ComponentHandler<ScanProbeLauncher>::name("scan_probe_launcher");
    BIND_MEMBER(ScanProbeLauncher, max);
    BIND_MEMBER(ScanProbeLauncher, stock);
    BIND_MEMBER(ScanProbeLauncher, recharge);
    BIND_MEMBER(ScanProbeLauncher, charge_time);
    sp::script::ComponentHandler<HackingDevice>::name("hacking_device");
    sp::script::ComponentHandler<PlayerControl>::name("player_control");
    //TODO: BIND_MEMBER(PlayerControl, alert_level);
    BIND_MEMBER(PlayerControl, control_code);

    sp::script::ComponentHandler<Faction>::name("faction");
    BIND_MEMBER(Faction, entity);

    sp::script::ComponentHandler<FactionInfo>::name("faction_info");
    BIND_MEMBER(FactionInfo, gm_color);
    BIND_MEMBER(FactionInfo, name);
    BIND_MEMBER(FactionInfo, locale_name);
    BIND_MEMBER(FactionInfo, description);
    BIND_MEMBER(FactionInfo, reputation_points);
    BIND_ARRAY(FactionInfo, relations);
    BIND_ARRAY_MEMBER(FactionInfo, relations, other_faction);
    BIND_ARRAY_MEMBER(FactionInfo, relations, relation);

    sp::script::ComponentHandler<AIController>::name("ai_controller");
    BIND_MEMBER(AIController, orders);
    BIND_MEMBER(AIController, order_target_location);
    BIND_MEMBER(AIController, order_target);
    BIND_MEMBER(AIController, new_name);

    sp::script::ComponentHandler<ConstantParticleEmitter>::name("constant_particle_emitter");
    BIND_MEMBER(ConstantParticleEmitter, interval);
    BIND_MEMBER(ConstantParticleEmitter, travel_random_range);
    BIND_MEMBER(ConstantParticleEmitter, start_color);
    BIND_MEMBER(ConstantParticleEmitter, end_color);
    BIND_MEMBER(ConstantParticleEmitter, start_size);
    BIND_MEMBER(ConstantParticleEmitter, end_size);
    BIND_MEMBER(ConstantParticleEmitter, life_time);

    sp::script::ComponentHandler<RadarBlock>::name("radar_block");
    BIND_MEMBER(RadarBlock, range);
    BIND_MEMBER(RadarBlock, behind);
    sp::script::ComponentHandler<NeverRadarBlocked>::name("never_radar_blocked");

    sp::script::ComponentHandler<NebulaRenderer>::name("nebula_renderer");
    BIND_ARRAY(NebulaRenderer, clouds);
    BIND_ARRAY_MEMBER(NebulaRenderer, clouds, offset);
    BIND_ARRAY_MEMBER_NAMED(NebulaRenderer, clouds, "texture", texture.name);
    BIND_ARRAY_MEMBER(NebulaRenderer, clouds, size);

    sp::script::ComponentHandler<Gravity>::name("gravity");
    BIND_MEMBER(Gravity, range);
    BIND_MEMBER(Gravity, force);
    BIND_MEMBER(Gravity, damage);
    BIND_MEMBER(Gravity, wormhole_target);
    //todo: on_teleportation
}
