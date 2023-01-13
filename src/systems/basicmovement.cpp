#include "basicmovement.h"
#include "components/spin.h"
#include "components/collision.h"
#include "ecs/query.h"

void BasicMovementSystem::update(float delta)
{
    if (delta <= 0.0f) return;

    for(auto [entity, spin, transform] : sp::ecs::Query<Spin, sp::Transform>()) {
        transform.setRotation(transform.getRotation() + delta * spin.rate);
    }
}
