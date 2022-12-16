#include "systems/shieldsystem.h"

#include "components/shields.h"
#include "components/docking.h"
#include "components/reactor.h"
#include "ecs/query.h"


void ShieldSystem::update(float delta)
{
    for(auto [entity, shields, reactor] : sp::ecs::Query<Shields, sp::ecs::optional<Reactor>>())
    {
        // If shields are calibrating, tick the calibration delay. Factor shield
        // subsystem effectiveness when determining the tick rate.
        if (shields.calibration_delay > 0.0) {
            shields.calibration_delay -= delta * (shields.front_system.getSystemEffectiveness() * shields.rear_system.getSystemEffectiveness()) * 0.5f;
            shields.active = false;
        }
        if (shields.active && reactor) {
            // Consume power if shields are enabled.
            if (!reactor->useEnergy(delta * shields.energy_use_per_second))
                shields.active = false;
        }
        for(int n=0; n<shields.count; n++)
        {
            auto& shield = shields.entry[n];
            if (shield.level < shield.max)
            {
                float rate = 0.3f;
                rate *= shields.getSystemForIndex(n).getSystemEffectiveness();

                auto port = entity.getComponent<DockingPort>();
                if (port && port->state == DockingPort::State::Docked && port->target)
                {
                    auto bay = port->target.getComponent<DockingBay>();
                    if (bay && (bay->flags & DockingBay::ChargeShield))
                        rate *= 4.0f;
                }

                shield.level = std::min(shield.max, shield.level + delta * rate);
            }
            if (shield.hit_effect > 0)
                shield.hit_effect -= delta;
        }

    }
}
