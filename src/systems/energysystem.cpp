#include "energysystem.h"
#include "ecs/query.h"
#include "components/coolant.h"
#include "components/reactor.h"
#include "components/hull.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/explosionEffect.h"
#include "multiplayer_server.h"


void EnergySystem::update(float delta)
{
    for(auto[entity, reactor] : sp::ecs::Query<Reactor>()) {
        // Consume power based on subsystem requests and state.
        float net_power = 0.0;
        // Determine each subsystem's energy draw.
        for(int n = 0; n < ShipSystem::COUNT; n++)
        {
            const auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
            if (!sys) continue;
            // Factor the subsystem's health into energy generation.
            auto power_user_factor = sys->power_factor * sys->power_factor_rate;

            if (power_user_factor < 0)
            {
                float f = sys->getSystemEffectiveness();
                if (f > 1.0f)
                    f = (1.0f + f) / 2.0f;
                net_power -= power_user_factor * f;
            }
            else
            {
                net_power -= power_user_factor * sys->power_level;
            }
        }

        reactor.energy += delta * net_power;
        // Cap energy at the max_energy_level.
        reactor.energy = std::clamp(reactor.energy, 0.0f, reactor.max_energy);

        // If reactor health is worse than -90% and overheating, it explodes,
        // destroying the ship and damaging a 0.5U radius.
        if (reactor.health < -0.9f && reactor.heat_level == 1.0f && game_server)
        {
            auto hull = entity.getComponent<Hull>();
            if (hull && hull->allow_destruction) {
                auto obj_ptr = entity.getComponent<SpaceObject*>();
                if (obj_ptr) {
                    auto obj = *obj_ptr;
                    auto e = new ExplosionEffect();
                    e->setSize(1000.0f);
                    e->setPosition(obj->getPosition());
                    e->setRadarSignatureInfo(0.0, 0.4, 0.4);

                    DamageInfo info(obj, DT_Kinetic, obj->getPosition());
                    SpaceObject::damageArea(obj->getPosition(), 500, 30, 60, info, 0.0);

                    obj->destroy();
                }
            }
        }
    }
}