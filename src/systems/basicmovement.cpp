#include "basicmovement.h"
#include "components/spin.h"
#include "components/orbit.h"
#include "components/collision.h"
#include "components/moveto.h"
#include "ecs/query.h"
#include "vectorUtils.h"
#include "menus/luaConsole.h"
#include "multiplayer_server.h"


void BasicMovementSystem::update(float delta)
{
    if (delta <= 0.0f) return;

    for(auto [entity, spin, transform] : sp::ecs::Query<Spin, sp::Transform>()) {
        transform.setRotationNoReplication(transform.getRotation() + delta * spin.rate);
    }

    for(auto [entity, orbit, transform] : sp::ecs::Query<Orbit, sp::Transform>()) {
        if (auto tt = orbit.target.getComponent<sp::Transform>())
            orbit.center = tt->getPosition();

        float angle = vec2ToAngle(transform.getPosition() - orbit.center);
        if (orbit.time != 0)
            angle += delta / orbit.time * 360.0f;
        transform.setPositionNoReplication(orbit.center + vec2FromAngle(angle) * orbit.distance);
    }

    for(auto [entity, moveto, transform] : sp::ecs::Query<MoveTo, sp::Transform>()) {
        auto diff = moveto.target - transform.getPosition();
        float movement = delta * moveto.speed;
        float distance = glm::length2(diff);

        if (distance > 100.0f * 100.0f)
        {
            auto v = glm::normalize(diff);
            transform.setRotationNoReplication(vec2ToAngle(v));
            if (distance < movement * movement)
                movement = std::sqrt(distance);
            transform.setPositionNoReplication(transform.getPosition() + v * movement);
        }
        else if (game_server)
        {
            if (moveto.on_arrival)
                LuaConsole::checkResult(moveto.on_arrival.call<void>(entity, transform.getPosition().x, transform.getPosition().y));
            entity.removeComponent<MoveTo>();
        }
    }
}
