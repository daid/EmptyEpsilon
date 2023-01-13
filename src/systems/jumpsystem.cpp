#include "systems/jumpsystem.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "components/jumpdrive.h"
#include "components/warpdrive.h"
#include "components/reactor.h"
#include "spaceObjects/warpJammer.h"
#include "ecs/query.h"
#include "random.h"


void JumpSystem::update(float delta)
{
    for(auto [entity, jump, position, physics] : sp::ecs::Query<JumpDrive, sp::Transform, sp::Physics>())
    {
        if (jump.delay > 0.0f)
        {
            if (WarpJammer::isWarpJammed(position.getPosition()))
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

            jump.delay -= delta * jump.getSystemEffectiveness();
            if (jump.delay <= 0.0f)
            {
                float f = jump.health;
                if (f <= 0.0f)
                    return;

                // When jumping, reset the jump effect and move the ship.
                jump.just_jumped = 2.0f;

                auto distance = (jump.distance * f) + (jump.distance * (1.0f - f) * random(0.5, 1.5));
                auto target_position = position.getPosition() + vec2FromAngle(position.getRotation()) * distance;
                target_position = WarpJammer::getFirstNoneJammedPosition(position.getPosition(), target_position);
                position.setPosition(target_position);
                jump.addHeat(jump.heat_per_jump);

                jump.delay = 0.f;
            }
        } else {
            float f = jump.get_recharge_rate();
            if (f > 0)
            {
                if (jump.charge < jump.max_distance)
                {
                    float extra_charge = (delta / jump.charge_time * jump.max_distance) * f;
                    auto reactor = entity.getComponent<Reactor>();
                    if (!reactor || reactor->useEnergy(extra_charge * jump.energy_per_km_charge / 1000.0f))
                    {
                        jump.charge += extra_charge;
                        if (jump.charge >= jump.max_distance)
                            jump.charge = jump.max_distance;
                    }
                }
            }else{
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
    if (jump->delay <= 0.0f)
    {
        jump->distance = distance;
        jump->delay = 10.f;
        jump->charge -= distance;
    }
}