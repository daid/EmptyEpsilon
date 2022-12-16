#include "systems/warpsystem.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/reactor.h"
#include "components/shields.h"
#include "spaceObjects/warpjammer.h"
#include "ecs/query.h"


void WarpSystem::update(float delta)
{
    for(auto [entity, warp, impulse, position, physics] : sp::ecs::Query<WarpDrive, sp::ecs::optional<ImpulseEngine>, sp::Transform, sp::Physics>())
    {
        if (warp.request > 0 || warp.current > 0)
        {
            if (WarpJammer::isWarpJammed(position.getPosition()))
                warp.request = 0;
        }
        if (warp.request > 0 || warp.current > 0)
        {
            if (impulse) {
                impulse->request = 1.0;
            }

            if (!impulse || impulse->actual >= 1.0f) {
                if (warp.current < warp.request)
                {
                    warp.current += delta / warp.charge_time;
                    if (warp.current > warp.request)
                        warp.current = warp.request;
                }else if (warp.current > warp.request)
                {
                    warp.current -= delta / warp.decharge_time;
                    if (warp.current < warp.request)
                        warp.current = warp.request;
                }
            }

            auto reactor = entity.getComponent<Reactor>();
            if (reactor) {
                // If warping, consume energy at a rate of 120% the warp request.
                // If shields are up, that rate is increased by an additional 50%.
                auto energy_use = warp.energy_warp_per_second * delta * warp.getSystemEffectiveness() * powf(warp.current, 1.3f);
                auto shields = entity.getComponent<Shields>();
                if (shields && shields->active)
                    energy_use *= 1.7f;
                if (!reactor->useEnergy(energy_use))
                    warp.request = 0;
            }
        }

        // Add heat based on warp factor.
        warp.addHeat(warp.current * delta * warp.heat_per_warp * warp.getSystemEffectiveness());

        // Determine forward direction and velocity.
        auto forward = vec2FromAngle(position.getRotation());
        auto current_velocity = physics.getVelocity();
        if (!impulse)
            current_velocity = glm::vec2{0, 0};
        physics.setVelocity(current_velocity + forward * (warp.current * warp.speed_per_level * warp.getSystemEffectiveness()));
    }
}
