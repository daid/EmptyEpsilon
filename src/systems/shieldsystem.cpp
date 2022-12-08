#include "systems/shieldsystem.h"

#include "components/shields.h"
#include "components/docking.h"
#include "ecs/query.h"


void ShieldSystem::update(float delta)
{
    for(auto [entity, shields] : sp::ecs::Query<Shields>())
    {
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
