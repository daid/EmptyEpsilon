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
        auto jump_effectiveness = jump.getSystemEffectiveness();
        jump.activation_rate = delta * jump_effectiveness;

        if (jump.delay > 0.0f && WarpSystem::isWarpJammed(entity))
            jump.delay = 0.0f;

        if (jump.just_jumped > 0.0f)
            jump.just_jumped -= delta;

        if (jump.delay > 0.0f)
        {
            // Full-halt other propulsion systems while a jump is in progress.
            if (auto impulse = entity.getComponent<ImpulseEngine>()) impulse->request = 0.0f;
            if (auto warp = entity.getComponent<WarpDrive>()) warp->request = 0;

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
            if (jump_effectiveness <= 0.0f)
                jump.effective_activation_delay = std::numeric_limits<float>::infinity();
            else
                jump.effective_activation_delay = (jump.activation_delay * (jump.delay / jump.activation_delay)) / jump_effectiveness;

            if (jump.delay <= 0.0f)
            {
                float health = jump.health;
                if (health <= 0.0f) return;

                // When jumping, reset the jump effect and move the ship.
                jump.just_jumped = 2.0f;

                auto distance = (jump.distance * health) + (jump.distance * (1.0f - health) * random(0.5f, 1.5f));
                auto target_position = position.getPosition() + vec2FromAngle(position.getRotation()) * distance;
                target_position = WarpSystem::getFirstNoneJammedPosition(position.getPosition(), target_position);
                position.setPosition(target_position);

                // Add heat if the entity uses coolant, and reset the jump delay.
                if (entity.hasComponent<Coolant>()) jump.addHeat(jump.heat_per_jump);

                jump.delay = 0.0f;
            }
        } else {
            // If a jump hasn't been initiated, reset the predicted countdown
            // value to the default fixed delay modified by the system's current
            // effectiveness. Also, track the current system effectiveness so we
            // can compare it for changes after the jump starts.
            if (jump_effectiveness <= 0.0f)
                jump.effective_activation_delay = std::numeric_limits<float>::infinity();
            else
                jump.effective_activation_delay = jump.activation_delay / jump_effectiveness;

            // Recharge the jump drive if its recharge rate > 0 and the ship has
            // energy to use or lacks or reactor.
            float recharge_rate = jump.get_recharge_rate();
            if (recharge_rate > 0.0f)
            {
                if (jump.charge < jump.max_distance)
                {
                    float extra_charge = (delta / jump.charge_time * jump.max_distance) * recharge_rate;
                    auto reactor = entity.getComponent<Reactor>();
                    if (!reactor || reactor->useEnergy(extra_charge * jump.energy_per_u_charge / 1000.0f))
                        jump.charge = std::min(jump.charge + extra_charge, jump.max_distance);
                }
            } else {
                jump.charge = std::max(0.0f, (delta / jump.charge_time * jump.max_distance) * recharge_rate);
            }
        }
    }
}

void JumpSystem::initializeJump(sp::ecs::Entity entity, float distance)
{
    // You can't jump if you don't have a jump drive.
    auto jump = entity.getComponent<JumpDrive>();
    if (!jump) return;

    // You can't jump if you're docked to a parent ship.
    auto docking_port = entity.getComponent<DockingPort>();
    if (docking_port && docking_port->state != DockingPort::State::NotDocking) return;

    // You can't jump before the drive is fully charged.
    if (jump->charge < jump->max_distance) return;

    distance = std::clamp(distance, jump->min_distance, jump->max_distance);

    if (jump->delay <= 0.0f)
    {
        jump->distance = distance;
        jump->delay = jump->activation_delay;
        jump->charge -= distance;
    }
}