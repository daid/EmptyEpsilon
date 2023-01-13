#include "systems/impulse.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "ecs/query.h"


void ImpulseSystem::update(float delta)
{
    for(auto [entity, impulse, physics, transform] : sp::ecs::Query<ImpulseEngine, sp::Physics, sp::Transform>())
    {
        //Here we want to have max speed at 100% impulse, and max reverse speed at -100% impulse
        float cap_speed = impulse.max_speed_forward;
        
        if(impulse.actual < 0 && impulse.max_speed_reverse <= 0.01f)
        {
            impulse.actual = 0; //we could get stuck with a ship with no reverse speed, not being able to accelerate
        }
        if(impulse.actual < 0) 
        {
            cap_speed = impulse.max_speed_reverse;
        }

        if (impulse.request > 1.0f)
            impulse.request = 1.0f;
        if (impulse.request < -1.0f)
            impulse.request = -1.0f;
        if (impulse.actual < impulse.request)
        {
            if (cap_speed > 0)
                impulse.actual += delta * (impulse.acceleration_forward / cap_speed);
            if (impulse.actual > impulse.request)
                impulse.actual = impulse.request;
        }else if (impulse.actual > impulse.request)
        {
            if (cap_speed > 0)
                impulse.actual -= delta * (impulse.acceleration_reverse / cap_speed);
            if (impulse.actual < impulse.request)
                impulse.actual = impulse.request;
        }

        // Determine forward direction and velocity.
        auto forward = vec2FromAngle(transform.getRotation());
        physics.setVelocity(forward * (impulse.actual * cap_speed * impulse.getSystemEffectiveness()));
    }
}
