#include "components.h"
#include "vector.h"
#include "enum.h"
#include "script/crewPosition.h"
#include "script/environment.h"
#include "script/component.h"
#include "script/callback.h"
#include "components/collision.h"
#include "components/radar.h"
#include "components/sfx.h"
#include "components/rendering.h"
#include "components/spin.h"
#include "components/orbit.h"
#include "components/avoidobject.h"
#include "components/missile.h"
#include "components/name.h"
#include "components/moveto.h"
#include "components/lifetime.h"
#include "components/hull.h"
#include "components/shields.h"
#include "components/docking.h"
#include "components/beamweapon.h"
#include "components/target.h"
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
#include "components/comms.h"
#include "components/faction.h"
#include "components/ai.h"
#include "ai/ai.h"
#include "components/radarblock.h"
#include "components/gravity.h"
#include "components/internalrooms.h"
#include "components/database.h"
#include "components/pickup.h"
#include "components/customshipfunction.h"
#include "components/zone.h"
#include "components/shiplog.h"


#define STRINGIFY(n) #n
#define BIND_MEMBER(T, MEMBER) \
    sp::script::ComponentHandler<T>::members[STRINGIFY(MEMBER)] = { \
        [](lua_State* L, const void* ptr) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<decltype(t->MEMBER)>::toLua(L, t->MEMBER); \
        }, [](lua_State* L, void* ptr) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->MEMBER = sp::script::Convert<decltype(t->MEMBER)>::fromLua(L, -1); \
        } \
    };
#define BIND_MEMBER_NAMED(T, MEMBER, NAME) \
    sp::script::ComponentHandler<T>::members[NAME] = { \
        [](lua_State* L, const void* ptr) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<std::remove_cv_t<std::remove_reference_t<decltype(t->MEMBER)>>>::toLua(L, t->MEMBER); \
        }, [](lua_State* L, void* ptr) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->MEMBER = sp::script::Convert<std::remove_cv_t<std::remove_reference_t<decltype(t->MEMBER)>>>::fromLua(L, -1); \
        } \
    };
#define BIND_MEMBER_GS(T, NAME, GET, SET) \
    sp::script::ComponentHandler<T>::members[NAME] = { \
        [](lua_State* L, const void* ptr) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<decltype(std::declval<T>().GET())>::toLua(L, t->GET()); \
        }, [](lua_State* L, void* ptr) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->SET(sp::script::Convert<decltype(std::declval<T>().GET())>::fromLua(L, -1)); \
        } \
    };
#define BIND_MEMBER_FLAG(T, MEMBER, NAME, MASK) \
    sp::script::ComponentHandler<T>::members[NAME] = { \
        [](lua_State* L, const void* ptr) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<bool>::toLua(L, ((t->MEMBER) & (MASK)) == (MASK) ); \
        }, [](lua_State* L, void* ptr) { \
            auto t = reinterpret_cast<T*>(ptr); \
            auto result = (t->MEMBER) & ~(MASK); \
            if (sp::script::Convert<bool>::fromLua(L, -1)) result |= (MASK); \
            t->MEMBER = result; \
        } \
    };
#define BIND_ARRAY(T, A) \
    sp::script::ComponentHandler<T>::array_count_func = [](const T& t) -> int { return t.A.size(); }; \
    sp::script::ComponentHandler<T>::array_resize_func = [](T& t, int new_size) { t.A.resize(new_size); }; \
    sp::script::ComponentHandler<T>::indexed_members["length"] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<int>::toLua(L, t->A.size()); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->A.resize(std::max(0, sp::script::Convert<int>::fromLua(L, -1))); \
        } \
    };
#define BIND_ARRAY_MEMBER(T, A, MEMBER) \
    sp::script::ComponentHandler<T>::indexed_members[STRINGIFY(MEMBER)] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<decltype(t->A[n].MEMBER)>::toLua(L, t->A[n].MEMBER); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->A[n].MEMBER = sp::script::Convert<decltype(t->A[n].MEMBER)>::fromLua(L, -1); \
        } \
    };
#define BIND_ARRAY_MEMBER_FLAG(T, A, MEMBER, NAME, MASK) \
    sp::script::ComponentHandler<T>::indexed_members[NAME] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<bool>::toLua(L, ((t->A[n].MEMBER) & (MASK)) == (MASK) ); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            auto result = (t->A[n].MEMBER) & ~(MASK); \
            if (sp::script::Convert<bool>::fromLua(L, -1)) result |= (MASK); \
            t->A[n].MEMBER = result; \
        } \
    };
#define BIND_ARRAY_MEMBER_NAMED(T, A, NAME, MEMBER) \
    sp::script::ComponentHandler<T>::indexed_members[NAME] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<decltype(t->A[n].MEMBER)>::toLua(L, t->A[n].MEMBER); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->A[n].MEMBER = sp::script::Convert<decltype(t->A[n].MEMBER)>::fromLua(L, -1); \
        } \
    };
#define BIND_ARRAY_DIRTY_FLAG(T, A, DIRTY) \
    sp::script::ComponentHandler<T>::array_count_func = [](const T& t) -> int { return t.A.size(); }; \
    sp::script::ComponentHandler<T>::array_resize_func = [](T& t, int new_size) { t.A.resize(new_size); t.DIRTY = true; };
#define BIND_ARRAY_DIRTY_FLAG_MEMBER(T, A, MEMBER, DIRTY) \
    sp::script::ComponentHandler<T>::indexed_members[STRINGIFY(MEMBER)] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<decltype(t->A[n].MEMBER)>::toLua(L, t->A[n].MEMBER); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->A[n].MEMBER = sp::script::Convert<decltype(t->A[n].MEMBER)>::fromLua(L, -1); t->DIRTY = true; \
        } \
    };
#define BIND_ARRAY_DIRTY_FLAG_MEMBER_FLAG(T, A, MEMBER, NAME, MASK, DIRTY) \
    sp::script::ComponentHandler<T>::indexed_members[NAME] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<bool>::toLua(L, ((t->A[n].MEMBER) & (MASK)) == (MASK) ); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            auto result = (t->A[n].MEMBER) & ~(MASK); \
            if (sp::script::Convert<bool>::fromLua(L, -1)) result |= (MASK); \
            t->A[n].MEMBER = result; t->DIRTY = true; \
        } \
    };
#define BIND_ARRAY_DIRTY_FLAG_MEMBER_NAMED(T, A, NAME, MEMBER, DIRTY) \
    sp::script::ComponentHandler<T>::indexed_members[NAME] = { \
        [](lua_State* L, const void* ptr, int n) { \
            auto t = reinterpret_cast<const T*>(ptr); \
            return sp::script::Convert<decltype(t->A[n].MEMBER)>::toLua(L, t->A[n].MEMBER); \
        }, [](lua_State* L, void* ptr, int n) { \
            auto t = reinterpret_cast<T*>(ptr); \
            t->A[n].MEMBER = sp::script::Convert<decltype(t->A[n].MEMBER)>::fromLua(L, -1); t->DIRTY = true; \
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
    BIND_MEMBER(T, auto_repair_per_second); \
    BIND_MEMBER(T, damage_per_second_on_overheat);


void initComponentScriptBindings()
{
    sp::script::ComponentHandler<sp::Transform>::name("transform");
    sp::script::ComponentHandler<sp::Transform>::members["x"] = {
        [](lua_State* L, const void* ptr) {
            auto t = reinterpret_cast<const sp::Transform*>(ptr);
            return sp::script::Convert<float>::toLua(L, t->getPosition().x);
        }, [](lua_State* L, void* ptr) {
            auto t = reinterpret_cast<sp::Transform*>(ptr);
            t->setPosition({sp::script::Convert<float>::fromLua(L, -1), t->getPosition().y});
        }
    };
    sp::script::ComponentHandler<sp::Transform>::members["y"] = {
        [](lua_State* L, const void* ptr) {
            auto t = reinterpret_cast<const sp::Transform*>(ptr);
            return sp::script::Convert<float>::toLua(L, t->getPosition().y);
        }, [](lua_State* L, void* ptr) {
            auto t = reinterpret_cast<sp::Transform*>(ptr);
            t->setPosition({t->getPosition().x, sp::script::Convert<float>::fromLua(L, -1)});
        }
    };
    BIND_MEMBER_GS(sp::Transform, "position", getPosition, setPosition);
    sp::script::ComponentHandler<sp::Transform>::members["rotation"] = {
        [](lua_State* L, const void* ptr) {
            auto t = reinterpret_cast<const sp::Transform*>(ptr);
            return sp::script::Convert<float>::toLua(L, t->getRotation());
        }, [](lua_State* L, void* ptr) {
            auto t = reinterpret_cast<sp::Transform*>(ptr);
            t->setRotation(sp::script::Convert<float>::fromLua(L, -1));
        }
    };
    sp::script::ComponentHandler<sp::Physics>::name("physics");
    BIND_MEMBER_GS(sp::Physics, "type", getType, setType);
    sp::script::ComponentHandler<sp::Physics>::members["size"] = {
        [](lua_State* L, const void* ptr) {
            auto p = reinterpret_cast<const sp::Physics*>(ptr);
            if (p->getShape() == sp::Physics::Shape::Rectangle)
                return sp::script::Convert<glm::vec2>::toLua(L, p->getSize());
            return sp::script::Convert<float>::toLua(L, p->getSize().x);
        }, [](lua_State* L, void* ptr) {
            auto p = reinterpret_cast<sp::Physics*>(ptr);
            if (lua_istable(L, -1))
                p->setRectangle(p->getType(), sp::script::Convert<glm::vec2>::fromLua(L, -1));
            else
                p->setCircle(p->getType(), sp::script::Convert<float>::fromLua(L, -1));
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
    sp::script::ComponentHandler<DynamicRadarSignatureInfo>::name("dynamic_radar_signature");
    BIND_MEMBER(DynamicRadarSignatureInfo, gravity);
    BIND_MEMBER(DynamicRadarSignatureInfo, electrical);
    BIND_MEMBER(DynamicRadarSignatureInfo, biological);

    sp::script::ComponentHandler<MeshRenderComponent>::name("mesh_render");
    BIND_MEMBER_NAMED(MeshRenderComponent, mesh.name, "mesh");
    BIND_MEMBER_NAMED(MeshRenderComponent, texture.name, "texture");
    BIND_MEMBER_NAMED(MeshRenderComponent, specular_texture.name, "specular_texture");
    BIND_MEMBER_NAMED(MeshRenderComponent, illumination_texture.name, "illumination_texture");
    BIND_MEMBER(MeshRenderComponent, mesh_offset);
    BIND_MEMBER(MeshRenderComponent, scale);
    sp::script::ComponentHandler<BillboardRenderer>::name("billboard_render");
    BIND_MEMBER(BillboardRenderer, texture);
    BIND_MEMBER(BillboardRenderer, size);
    sp::script::ComponentHandler<EngineEmitter>::name("engine_emitter");
    BIND_ARRAY_DIRTY_FLAG(EngineEmitter, emitters, emitters_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(EngineEmitter, emitters, position, emitters_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(EngineEmitter, emitters, color, emitters_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(EngineEmitter, emitters, scale, emitters_dirty);

    sp::script::ComponentHandler<PlanetRender>::name("planet_render");
    BIND_MEMBER(PlanetRender, size);
    BIND_MEMBER(PlanetRender, cloud_size);
    BIND_MEMBER(PlanetRender, atmosphere_size);
    BIND_MEMBER(PlanetRender, texture);
    BIND_MEMBER(PlanetRender, cloud_texture);
    BIND_MEMBER(PlanetRender, atmosphere_texture);
    BIND_MEMBER(PlanetRender, atmosphere_color);
    BIND_MEMBER(PlanetRender, distance_from_movement_plane);

    sp::script::ComponentHandler<Spin>::name("spin");
    BIND_MEMBER(Spin, rate);
    sp::script::ComponentHandler<Orbit>::name("orbit");
    BIND_MEMBER(Orbit, target);
    BIND_MEMBER(Orbit, center);
    BIND_MEMBER(Orbit, distance);
    BIND_MEMBER(Orbit, time);

    sp::script::ComponentHandler<AvoidObject>::name("avoid_object");
    BIND_MEMBER(AvoidObject, range);

    sp::script::ComponentHandler<DelayedAvoidObject>::name("delayed_avoid_object");
    BIND_MEMBER(DelayedAvoidObject, delay);
    BIND_MEMBER(DelayedAvoidObject, range);

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

    sp::script::ComponentHandler<ExplosionEffect>::name("explosion_effect");
    BIND_MEMBER(ExplosionEffect, size);
    BIND_MEMBER(ExplosionEffect, radar);
    BIND_MEMBER(ExplosionEffect, electrical);

    sp::script::ComponentHandler<Sfx>::name("sfx");
    BIND_MEMBER(Sfx, sound);
    BIND_MEMBER(Sfx, power);
    BIND_MEMBER(Sfx, played);

    sp::script::ComponentHandler<CallSign>::name("callsign");
    BIND_MEMBER(CallSign, callsign);
    sp::script::ComponentHandler<TypeName>::name("typename");
    BIND_MEMBER(TypeName, type_name);
    BIND_MEMBER(TypeName, localized);

    sp::script::ComponentHandler<LongRangeRadar>::name("long_range_radar");
    BIND_MEMBER(LongRangeRadar, short_range);
    BIND_MEMBER(LongRangeRadar, long_range);
    BIND_MEMBER(LongRangeRadar, radar_view_linked_entity);
    BIND_ARRAY_DIRTY_FLAG(LongRangeRadar, waypoints, waypoints_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(LongRangeRadar, waypoints, x, waypoints_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(LongRangeRadar, waypoints, y, waypoints_dirty);
    BIND_MEMBER(LongRangeRadar, on_probe_link);
    BIND_MEMBER(LongRangeRadar, on_probe_unlink);
    sp::script::ComponentHandler<ShareShortRangeRadar>::name("share_short_range_radar");
    sp::script::ComponentHandler<AllowRadarLink>::name("allow_radar_link");
    BIND_MEMBER(AllowRadarLink, owner);

    sp::script::ComponentHandler<Hull>::name("hull");
    BIND_MEMBER(Hull, current);
    BIND_MEMBER(Hull, max);
    BIND_MEMBER(Hull, allow_destruction);
    BIND_MEMBER(Hull, on_destruction);
    BIND_MEMBER(Hull, on_taking_damage);
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
    BIND_MEMBER_NAMED(Shields, front_system.damage_per_second_on_overheat, "front_damage_per_second_on_overheat");
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
    BIND_MEMBER_NAMED(Shields, rear_system.damage_per_second_on_overheat, "rear_damage_per_second_on_overheat");

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
    BIND_MEMBER(DockingPort, state);
    BIND_MEMBER(DockingPort, target);
    BIND_MEMBER(DockingPort, auto_reload_missiles);
    BIND_MEMBER(DockingPort, auto_reload_missile_time);

    sp::script::ComponentHandler<DockingBay>::name("docking_bay");
    BIND_MEMBER_FLAG(DockingBay, flags, "share_energy", DockingBay::ShareEnergy);
    BIND_MEMBER_FLAG(DockingBay, flags, "repair", DockingBay::Repair);
    BIND_MEMBER_FLAG(DockingBay, flags, "charge_shields", DockingBay::ChargeShield);
    BIND_MEMBER_FLAG(DockingBay, flags, "restock_probes", DockingBay::RestockProbes);
    BIND_MEMBER_FLAG(DockingBay, flags, "restock_missiles", DockingBay::RestockMissiles);
    sp::script::ComponentHandler<DockingBay>::members["external_dock_classes"] = {
        [](lua_State* L, const void* ptr) {
            auto bay = reinterpret_cast<const DockingBay*>(ptr);
            lua_createtable(L, bay->external_dock_classes.size(), 0);
            int idx = 1;
            for(const auto& c : bay->external_dock_classes) {
                lua_pushstring(L, c.c_str());
                lua_seti(L, -2, idx++);
            }
            return 1;
        }, [](lua_State* L, void* ptr) {
            auto p = reinterpret_cast<DockingBay*>(ptr);
            p->external_dock_classes.clear();
            if (lua_istable(L, -1)) {
                for(int idx = 1; lua_geti(L, -1, idx); idx++) {
                    p->external_dock_classes.insert(lua_tostring(L, -1));
                    lua_pop(L, 1);
                }
                lua_pop(L, 1);
            }
            p->external_dock_classes_dirty = true;
        }
    };
    sp::script::ComponentHandler<DockingBay>::members["internal_dock_classes"] = {
        [](lua_State* L, const void* ptr) {
            auto bay = reinterpret_cast<const DockingBay*>(ptr);
            lua_createtable(L, bay->internal_dock_classes.size(), 0);
            int idx = 1;
            for(const auto& c : bay->internal_dock_classes) {
                lua_pushstring(L, c.c_str());
                lua_seti(L, -2, idx++);
            }
            return 1;
        }, [](lua_State* L, void* ptr) {
            auto p = reinterpret_cast<DockingBay*>(ptr);
            p->internal_dock_classes.clear();
            if (lua_istable(L, -1)) {
                for(int idx = 1; lua_geti(L, -1, idx); idx++) {
                    p->internal_dock_classes.insert(lua_tostring(L, -1));
                    lua_pop(L, 1);
                }
                lua_pop(L, 1);
            }
            p->internal_dock_classes_dirty = true;
        }
    };
    sp::script::ComponentHandler<CommsTransmitter>::name("comms_transmitter");
    BIND_MEMBER(CommsTransmitter, state);
    BIND_MEMBER(CommsTransmitter, open_delay);
    BIND_MEMBER(CommsTransmitter, target_name);
    BIND_MEMBER(CommsTransmitter, incomming_message);
    BIND_MEMBER(CommsTransmitter, target);

    sp::script::ComponentHandler<CommsReceiver>::name("comms_receiver");
    BIND_MEMBER(CommsReceiver, script);
    BIND_MEMBER(CommsReceiver, callback);

    sp::script::ComponentHandler<BeamWeaponSys>::name("beam_weapons");
    BIND_SHIP_SYSTEM(BeamWeaponSys);
    BIND_MEMBER(BeamWeaponSys, frequency);
    BIND_MEMBER(BeamWeaponSys, system_target);
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
    BIND_ARRAY_MEMBER(BeamWeaponSys, mounts, texture);
    sp::script::ComponentHandler<Target>::name("weapons_target");
    BIND_MEMBER(Target, entity);
    sp::script::ComponentHandler<BeamEffect>::name("beam_effect");
    BIND_MEMBER(BeamEffect, lifetime);
    BIND_MEMBER(BeamEffect, fade_speed);
    BIND_MEMBER(BeamEffect, source);
    BIND_MEMBER(BeamEffect, target);
    BIND_MEMBER(BeamEffect, source_offset);
    BIND_MEMBER(BeamEffect, target_offset);
    BIND_MEMBER(BeamEffect, target_location);
    BIND_MEMBER(BeamEffect, hit_normal);
    BIND_MEMBER(BeamEffect, fire_ring);
    BIND_MEMBER(BeamEffect, beam_texture);

    sp::script::ComponentHandler<Reactor>::name("reactor");
    BIND_SHIP_SYSTEM(Reactor);
    BIND_MEMBER(Reactor, max_energy);
    BIND_MEMBER(Reactor, energy);
    BIND_MEMBER(Reactor, overload_explode);

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
    BIND_MEMBER(CombatManeuveringThrusters, charge_time);
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.speed, "boost_speed");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.speed, "strafe_speed");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.request, "boost_request");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.request, "strafe_request");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.active, "boost_active");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.active, "strafe_active");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.max_time, "boost_max_time");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.max_time, "strafe_max_time");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, boost.heat_per_second, "boost_heat_per_second");
    BIND_MEMBER_NAMED(CombatManeuveringThrusters, strafe.heat_per_second, "strafe_heat_per_second");
    sp::script::ComponentHandler<WarpDrive>::name("warp_drive");
    BIND_SHIP_SYSTEM(WarpDrive);
    BIND_MEMBER(WarpDrive, charge_time);
    BIND_MEMBER(WarpDrive, decharge_time);
    BIND_MEMBER(WarpDrive, heat_per_warp);
    BIND_MEMBER(WarpDrive, max_level);
    BIND_MEMBER(WarpDrive, speed_per_level);
    BIND_MEMBER(WarpDrive, energy_warp_per_second);
    BIND_MEMBER(WarpDrive, request);
    BIND_MEMBER(WarpDrive, current);
    sp::script::ComponentHandler<WarpJammer>::name("warp_jammer");
    BIND_MEMBER(WarpJammer, range);
    sp::script::ComponentHandler<JumpDrive>::name("jump_drive");
    BIND_SHIP_SYSTEM(JumpDrive);
    BIND_MEMBER(JumpDrive, charge_time);
    BIND_MEMBER(JumpDrive, energy_per_km_charge);
    BIND_MEMBER(JumpDrive, heat_per_jump);
    BIND_MEMBER(JumpDrive, min_distance);
    BIND_MEMBER(JumpDrive, max_distance);
    BIND_MEMBER(JumpDrive, activation_delay);
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
    BIND_ARRAY_MEMBER_FLAG(MissileTubes, mounts, type_allowed_mask, "allow_homing", 1 << MW_Homing);
    BIND_ARRAY_MEMBER_FLAG(MissileTubes, mounts, type_allowed_mask, "allow_nuke", 1 << MW_Nuke);
    BIND_ARRAY_MEMBER_FLAG(MissileTubes, mounts, type_allowed_mask, "allow_mine", 1 << MW_Mine);
    BIND_ARRAY_MEMBER_FLAG(MissileTubes, mounts, type_allowed_mask, "allow_emp", 1 << MW_EMP);
    BIND_ARRAY_MEMBER_FLAG(MissileTubes, mounts, type_allowed_mask, "allow_hvli", 1 << MW_HVLI);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, direction);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, size);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, type_loaded);
    BIND_ARRAY_MEMBER(MissileTubes, mounts, state);
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
    sp::script::ComponentHandler<ScienceDescription>::name("science_description");
    BIND_MEMBER(ScienceDescription, not_scanned);
    BIND_MEMBER(ScienceDescription, friend_or_foe_identified);
    BIND_MEMBER(ScienceDescription, simple_scan);
    BIND_MEMBER(ScienceDescription, full_scan);
    sp::script::ComponentHandler<ScienceScanner>::name("science_scanner");
    BIND_MEMBER(ScienceScanner, delay);
    BIND_MEMBER(ScienceScanner, max_scanning_delay);
    BIND_MEMBER(ScienceScanner, target);
    sp::script::ComponentHandler<ScanState>::name("scan_state");
    BIND_MEMBER(ScanState, allow_simple_scan);
    BIND_MEMBER(ScanState, complexity);
    BIND_MEMBER(ScanState, depth);
    BIND_ARRAY_DIRTY_FLAG(ScanState, per_faction, per_faction_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(ScanState, per_faction, faction, per_faction_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(ScanState, per_faction, state, per_faction_dirty);

    sp::script::ComponentHandler<ScanProbeLauncher>::name("scan_probe_launcher");
    BIND_MEMBER(ScanProbeLauncher, max);
    BIND_MEMBER(ScanProbeLauncher, stock);
    BIND_MEMBER(ScanProbeLauncher, recharge);
    BIND_MEMBER(ScanProbeLauncher, charge_time);
    BIND_MEMBER(ScanProbeLauncher, on_launch);
    sp::script::ComponentHandler<PlayerControl>::name("player_control");
    BIND_MEMBER(PlayerControl, alert_level);
    BIND_MEMBER(PlayerControl, control_code);
    BIND_MEMBER(PlayerControl, allowed_positions);
    sp::script::ComponentHandler<HackingDevice>::name("hacking_device");
    BIND_MEMBER(HackingDevice, effectiveness);
    sp::script::ComponentHandler<ShipLog>::name("ship_log");

    sp::script::ComponentHandler<MoveTo>::name("move_to");
    BIND_MEMBER(MoveTo, speed);
    BIND_MEMBER(MoveTo, target);
    BIND_MEMBER(MoveTo, on_arrival);
    sp::script::ComponentHandler<LifeTime>::name("lifetime");
    BIND_MEMBER(LifeTime, lifetime);
    BIND_MEMBER(LifeTime, on_expire);

    sp::script::ComponentHandler<Faction>::name("faction");
    BIND_MEMBER(Faction, entity);

    sp::script::ComponentHandler<FactionInfo>::name("faction_info");
    BIND_MEMBER(FactionInfo, gm_color);
    BIND_MEMBER(FactionInfo, name);
    BIND_MEMBER(FactionInfo, locale_name);
    BIND_MEMBER(FactionInfo, description);
    BIND_MEMBER(FactionInfo, reputation_points);
    BIND_ARRAY_DIRTY_FLAG(FactionInfo, relations, relations_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(FactionInfo, relations, other_faction, relations_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(FactionInfo, relations, relation, relations_dirty);

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
    BIND_MEMBER(NebulaRenderer, render_range);
    BIND_ARRAY_DIRTY_FLAG(NebulaRenderer, clouds, clouds_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(NebulaRenderer, clouds, offset, clouds_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER_NAMED(NebulaRenderer, clouds, "texture", texture.name, clouds_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(NebulaRenderer, clouds, size, clouds_dirty);

    sp::script::ComponentHandler<Gravity>::name("gravity");
    BIND_MEMBER(Gravity, range);
    BIND_MEMBER(Gravity, force);
    BIND_MEMBER(Gravity, damage);
    BIND_MEMBER(Gravity, wormhole_target);
    BIND_MEMBER(Gravity, on_teleportation);

    sp::script::ComponentHandler<InternalRooms>::name("internal_rooms");
    BIND_MEMBER(InternalRooms, auto_repair_enabled);
    BIND_ARRAY_DIRTY_FLAG(InternalRooms, rooms, rooms_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(InternalRooms, rooms, position, rooms_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(InternalRooms, rooms, size, rooms_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(InternalRooms, rooms, system, rooms_dirty);
    sp::script::ComponentHandler<InternalRooms>::members["doors"] = {
        [](lua_State* L, const void* ptr) {
            auto t = reinterpret_cast<const InternalRooms*>(ptr);
            lua_newtable(L);
            for(size_t n=0; n<t->doors.size(); n++) {
                lua_newtable(L);
                lua_pushinteger(L, t->doors[n].position.x); lua_seti(L, -2, 1);
                lua_pushinteger(L, t->doors[n].position.y); lua_seti(L, -2, 2);
                lua_pushboolean(L, t->doors[n].horizontal); lua_seti(L, -2, 3);
                lua_seti(L, -2, n+1);
            }
            return 1;
        }, [](lua_State* L, void* ptr) {
            auto t = reinterpret_cast<InternalRooms*>(ptr);
            t->doors.clear();
            while(true) {
                lua_geti(L, -1, t->doors.size() + 1);
                if (!lua_istable(L, -1))
                    break;
                lua_geti(L, -1, 1); auto x = lua_tonumber(L, -1); lua_pop(L, 1);
                lua_geti(L, -1, 2); auto y = lua_tonumber(L, -1); lua_pop(L, 1);
                lua_geti(L, -1, 3); bool horizontal = lua_toboolean(L, -1); lua_pop(L, 1);
                t->doors.push_back({{x, y}, horizontal});

                lua_pop(L, 1);
            }
            lua_pop(L, 1);
            t->doors_dirty = true;
        }
    };
    sp::script::ComponentHandler<InternalCrew>::name("internal_crew");
    BIND_MEMBER(InternalCrew, move_speed);
    BIND_MEMBER(InternalCrew, position);
    BIND_MEMBER(InternalCrew, target_position);
    //TODO: action, direction, action_delay
    BIND_MEMBER(InternalCrew, ship);
    sp::script::ComponentHandler<InternalRepairCrew>::name("internal_repair_crew");
    BIND_MEMBER(InternalRepairCrew, repair_per_second);
    BIND_MEMBER(InternalRepairCrew, unhack_per_second);

    sp::script::ComponentHandler<Database>::name("science_database");
    BIND_MEMBER(Database, name);
    BIND_MEMBER(Database, description);
    BIND_MEMBER(Database, image);
    BIND_MEMBER(Database, parent);
    BIND_ARRAY_DIRTY_FLAG(Database, key_values, key_values_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(Database, key_values, key, key_values_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(Database, key_values, value, key_values_dirty);

    sp::script::ComponentHandler<PickupCallback>::name("pickup");
    BIND_MEMBER(PickupCallback, callback);
    BIND_MEMBER(PickupCallback, player);
    BIND_MEMBER(PickupCallback, give_energy);
    BIND_MEMBER_NAMED(PickupCallback, give_missile[int(MW_Homing)], "give_homing");
    BIND_MEMBER_NAMED(PickupCallback, give_missile[int(MW_Nuke)], "give_nuke");
    BIND_MEMBER_NAMED(PickupCallback, give_missile[int(MW_Mine)], "give_mine");
    BIND_MEMBER_NAMED(PickupCallback, give_missile[int(MW_EMP)], "give_emp");
    BIND_MEMBER_NAMED(PickupCallback, give_missile[int(MW_HVLI)], "give_hvli");

    sp::script::ComponentHandler<CollisionCallback>::name("collision_callback");
    BIND_MEMBER(CollisionCallback, callback);
    BIND_MEMBER(CollisionCallback, player);

    sp::script::ComponentHandler<CustomShipFunctions>::name("custom_ship_functions");
    BIND_ARRAY_DIRTY_FLAG(CustomShipFunctions, functions, functions_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(CustomShipFunctions, functions, type, functions_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(CustomShipFunctions, functions, name, functions_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(CustomShipFunctions, functions, caption, functions_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(CustomShipFunctions, functions, crew_positions, functions_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(CustomShipFunctions, functions, callback, functions_dirty);
    BIND_ARRAY_DIRTY_FLAG_MEMBER(CustomShipFunctions, functions, order, functions_dirty);

    sp::script::ComponentHandler<Zone>::name("zone");
    BIND_MEMBER(Zone, color);
    BIND_MEMBER(Zone, label);
    BIND_MEMBER(Zone, skybox);
    BIND_MEMBER(Zone, skybox_fade_distance);
    sp::script::ComponentHandler<Zone>::members["points"] = {
        [](lua_State* L, const void* ptr) {
            auto zone = reinterpret_cast<const Zone*>(ptr);
            lua_newtable(L);
            for(size_t n=0; n<zone->outline.size(); n++) {
                lua_newtable(L);
                lua_pushnumber(L, zone->outline[n].x); lua_seti(L, -2, 1);
                lua_pushnumber(L, zone->outline[n].y); lua_seti(L, -2, 2);
                lua_seti(L, -2, n+1);
            }
            return 1;
        }, [](lua_State* L, void* ptr) {
            auto zone = reinterpret_cast<Zone*>(ptr);
            zone->outline.clear();
            while(true) {
                lua_geti(L, -1, zone->outline.size() + 1);
                if (!lua_istable(L, -1))
                    break;
                lua_geti(L, -1, 1); auto x = lua_tonumber(L, -1); lua_pop(L, 1);
                lua_geti(L, -1, 2); auto y = lua_tonumber(L, -1); lua_pop(L, 1);
                zone->outline.push_back({x, y});

                lua_pop(L, 1);
            }
            lua_pop(L, 1);

            zone->updateTriangles();
            zone->zone_dirty = true;
        }
    };
}
