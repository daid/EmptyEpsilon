#include "basicmovement.h"
#include "components/spin.h"
#include "components/orbit.h"
#include "components/collision.h"
#include "ecs/query.h"
#include "vectorUtils.h"


void BasicMovementSystem::update(float delta)
{
    if (delta <= 0.0f) return;

    for(auto [entity, spin, transform] : sp::ecs::Query<Spin, sp::Transform>()) {
        transform.setRotation(transform.getRotation() + delta * spin.rate);
    }

    for(auto [entity, orbit, transform] : sp::ecs::Query<Orbit, sp::Transform>()) {
        if (auto tt = orbit.target.getComponent<sp::Transform>())
            orbit.center = tt->getPosition();

        float angle = vec2ToAngle(transform.getPosition() - orbit.center);
        angle += delta / orbit.time * 360.0f;
        transform.setPosition(orbit.center + vec2FromAngle(angle) * orbit.distance);
    }
}
