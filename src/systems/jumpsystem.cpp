#include "systems/jumpsystem.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "components/jumpdrive.h"
#include "components/warpdrive.h"
#include "components/reactor.h"
#include "components/coolant.h"
#include "systems/warpsystem.h"
#include "ecs/query.h"
#include "random.h"


void JumpSystem::update(float delta)
{
    for(auto [entity, jump, position, physics] : sp::ecs::Query<JumpDrive, sp::Transform, sp::Physics>())
    {
        // Capture the jump activation rate as a factor of jump system effectiveness.
        jump.activation_rate = delta * jump.getSystemEffectiveness();

        if (jump.delay > 0.0f)
        {
            if (WarpSystem::isWarpJammed(entity))
                jump.delay = 0.0f;
        }
        if (jump.just_jumped > 0.0f)
            jump.just_jumped -= delta;
        if (jump.delay > 0.0f)
        {
            auto impulse = entity.getComponent<ImpulseEngine>();
            if (impulse)
                impulse->request = 0.0f;
            auto warp = entity.getComponent<WarpDrive>();
            if (warp)
                warp->request = 0;

            // The jump system "delay" is a fixed countdown with an upper limit
            // configured by jump.activation_delay, which defaults to 10.0.

            // If jump.delay = 10.0f and system effectiveness is 1.0
            //   (when all systems are at 100% power/undamaged/unhacked),
            //   a jump should take 10 seconds (jump.activation_delay).
            // If jump.delay = 10.0f and system effectiveness is 2.0,
            //   a jump should take half as long (5 seconds).
            // If jump.delay = 10.0f and system effectiveness is 0.5,
            //   a jump should take twice as long (20 seconds).

            // jump.effective_activation_delay tracks the actual number of
            // seconds remaining on the real-world clock before the in-progress
            // jump occurs, and is used by jumpControls and jumpIndicator UIs.

            // Tick the fixed jump delay down by the fixed activation rate
            // (delta * effectiveness). This doesn't necessarily reflect
            // real time when system effectiveness is improved or degraded.
            jump.delay -= jump.activation_rate;

            // Reset the countdown value based on how much of the
            // fixed-value jump.delay has elapsed and the new jump system
            // effectiveness this tick. This can cause the countdown to
            // apparently count down rapidly or unexpectedly count up,
            // for instance if power to the jump system changes mid-jump.
            jump.effective_activation_delay = (jump.activation_delay * (jump.delay / jump.activation_delay)) / std::max(0.01f, jump.getSystemEffectiveness());

            if (jump.delay <= 0.0f)
            {
                float f = jump.health;
                if (f <= 0.0f)
                    return;

                // When jumping, reset the jump effect and move the ship.
                jump.just_jumped = 2.0f;

                auto distance = (jump.distance * f) + (jump.distance * (1.0f - f) * random(0.5, 1.5));
                auto target_position = position.getPosition() + vec2FromAngle(position.getRotation()) * distance;
                target_position = WarpSystem::getFirstNoneJammedPosition(position.getPosition(), target_position);
                position.setPosition(target_position);
                if (entity.hasComponent<Coolant>())
                    jump.addHeat(jump.heat_per_jump);

                jump.delay = 0.f;
            }
        } else {
            // If a jump hasn't been initiated, reset the predicted countdown
            // value to the default fixed delay modified by the system's current
            // effectiveness. Also, track the current system effectiveness so we
            // can compare it for changes after the jump starts.
            jump.effective_activation_delay = jump.activation_delay / std::max(0.01f, jump.getSystemEffectiveness());

            float f = jump.get_recharge_rate();
            if (f > 0)
            {
                if (jump.charge < jump.max_distance)
                {
                    float extra_charge = (delta / jump.charge_time * jump.max_distance) * f;
                    auto reactor = entity.getComponent<Reactor>();
                    if (!reactor || reactor->useEnergy(extra_charge * jump.energy_per_u_charge / 1000.0f))
                    {
                        jump.charge += extra_charge;
                        if (jump.charge >= jump.max_distance)
                            jump.charge = jump.max_distance;
                    }
                }
            } else {
                jump.charge += (delta / jump.charge_time * jump.max_distance) * f;
                if (jump.charge < 0.0f)
                    jump.charge = 0.0f;
            }
        }
    }
}

void JumpSystem::initializeJump(sp::ecs::Entity entity, float distance)
{
    auto jump = entity.getComponent<JumpDrive>();
    if (!jump) return;
    auto docking_port = entity.getComponent<DockingPort>();
    if (docking_port && docking_port->state != DockingPort::State::NotDocking) return;
    if (jump->charge < jump->max_distance) // You can only jump when the drive is fully charged
        return;
    distance = std::clamp(distance, jump->min_distance, jump->max_distance);
    if (jump->delay <= 0.0f)
    {
        jump->distance = distance;
        jump->delay = jump->activation_delay;
        jump->charge -= distance;
    }
}