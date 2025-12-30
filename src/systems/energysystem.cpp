#include "energysystem.h"
#include "ecs/query.h"
#include "components/coolant.h"
#include "components/reactor.h"
#include "components/health.h"
#include "components/hull.h"
#include "components/collision.h"
#include "components/rendering.h"
#include "components/radar.h"
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

        if (reactor.energy < 10) {
            // Depower all systems except the reactor once energy level drops below 10.
            for(int n=0; n<ShipSystem::COUNT; n++) {
                auto type = ShipSystem::Type(n);
                if (type != ShipSystem::Type::Reactor) {
                    auto system = ShipSystem::get(entity, type);
                    if (system)
                        system->power_request = 0;
                }
            }
        }

        // If reactor health is worse than -90% and overheating, it explodes,
        // destroying the ship and damaging a 0.5U radius.
        if (reactor.health < -0.9f && reactor.heat_level == 1.0f && reactor.overload_explode && game_server)
        {
            auto health = entity.getComponent<Health>();
            if (health && health->allow_destruction) {
                auto transform = entity.getComponent<sp::Transform>();
                if (transform) {
                    auto e = sp::ecs::Entity::create();
                    e.addComponent<ExplosionEffect>().size = 1000.0;
                    e.addComponent<sp::Transform>(*transform);
                    e.addComponent<RawRadarSignatureInfo>(0.0f, 0.4f, 0.4f);

                    DamageInfo info(entity, DamageType::Kinetic, transform->getPosition());
                    DamageSystem::damageArea(transform->getPosition(), 500, 30, 60, info, 0.0);
                }

                entity.destroy();
            }
        }
    }
}