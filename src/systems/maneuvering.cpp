#include "systems/maneuvering.h"
#include "components/collision.h"
#include "components/maneuveringthrusters.h"
#include "components/impulse.h"
#include "components/coolant.h"
#include "ecs/query.h"
#include "vectorUtils.h"


void ManeuveringSystem::update(float delta)
{
    if (delta <= 0.0f) return;

    for(auto [entity, thrusters, transform, physics] : sp::ecs::Query<ManeuveringThrusters, sp::Transform, sp::Physics>()) {
        float rotationDiff = 0.0f;
        if (thrusters.rotation_request != std::numeric_limits<float>::min())
            rotationDiff = thrusters.rotation_request;
        if (thrusters.target != std::numeric_limits<float>::min())
            rotationDiff = angleDifference(transform.getRotation(), thrusters.target);

        auto maxSpeed = thrusters.speed * thrusters.getSystemEffectiveness();
        auto targetVelocity = rotationDiff / delta;

        physics.setAngularVelocity(std::clamp(targetVelocity, -maxSpeed, maxSpeed));
    }

    constexpr static float combat_maneuver_charge_time = 20.0f; /*< Amount of time it takes to fully charge the combat maneuver system */
    constexpr static float combat_maneuver_boost_max_time = 3.0f; /*< Amount of time we can boost with a fully charged combat maneuver system */
    constexpr static float combat_maneuver_strafe_max_time = 3.0f; /*< Amount of time we can strafe with a fully charged combat maneuver system */
    constexpr static float heat_per_combat_maneuver_boost = 0.2f;
    constexpr static float heat_per_combat_maneuver_strafe = 0.2f;

    for(auto [entity, combat] : sp::ecs::Query<CombatManeuveringThrusters>()) {
        if (combat.boost.active > combat.boost.request)
        {
            combat.boost.active -= delta;
            if (combat.boost.active < combat.boost.request)
                combat.boost.active = combat.boost.request;
        }
        if (combat.boost.active < combat.boost.request)
        {
            combat.boost.active += delta;
            if (combat.boost.active > combat.boost.request)
                combat.boost.active = combat.boost.request;
        }
        if (combat.strafe.active > combat.strafe.request)
        {
            combat.strafe.active -= delta;
            if (combat.strafe.active < combat.strafe.request)
                combat.strafe.active = combat.strafe.request;
        }
        if (combat.strafe.active < combat.strafe.request)
        {
            combat.strafe.active += delta;
            if (combat.strafe.active > combat.strafe.request)
                combat.strafe.active = combat.strafe.request;
        }

        // If the ship is making a combat maneuver ...
        if (combat.boost.active != 0.0f || combat.strafe.active != 0.0f)
        {
            // ... consume its combat maneuver boost.
            combat.charge -= fabs(combat.boost.active) * delta / combat_maneuver_boost_max_time;
            combat.charge -= fabs(combat.strafe.active) * delta / combat_maneuver_strafe_max_time;

            // Use boost only if we have boost available.
            if (combat.charge <= 0.0f)
            {
                combat.charge = 0.0f;
                combat.boost.request = 0.0f;
                combat.strafe.request = 0.0f;
            }else{
                auto physics = entity.getComponent<sp::Physics>();
                auto transform = entity.getComponent<sp::Transform>();
                if (physics && transform)
                {
                    auto forward = vec2FromAngle(transform->getRotation());
                    physics->setVelocity(physics->getVelocity() + forward * combat.boost.speed * combat.boost.active);
                    physics->setVelocity(physics->getVelocity() + vec2FromAngle(transform->getRotation() + 90) * combat.strafe.speed * combat.strafe.active);
                }
                // Add heat to systems consuming combat maneuver boost.
                auto thrusters = entity.getComponent<ManeuveringThrusters>();
                if (thrusters && entity.hasComponent<Coolant>())
                    thrusters->addHeat(std::abs(combat.strafe.active) * delta * heat_per_combat_maneuver_strafe);
                auto impulse = entity.getComponent<ImpulseEngine>();
                if (impulse && entity.hasComponent<Coolant>())
                    impulse->addHeat(std::abs(combat.boost.active) * delta * heat_per_combat_maneuver_boost);
            }
        }else if (combat.charge < 1.0f)
        {
            // If the ship isn't making a combat maneuver, recharge its boost.
            auto thrusters = entity.getComponent<ManeuveringThrusters>();
            if (thrusters)
                combat.charge += (delta / combat_maneuver_charge_time) * thrusters->getSystemEffectiveness() * 0.5f;
            auto impulse = entity.getComponent<ImpulseEngine>();
            if (impulse)
                combat.charge += (delta / combat_maneuver_charge_time) * impulse->getSystemEffectiveness() * 0.5f;
            if (combat.charge > 1.0f)
                combat.charge = 1.0f;
        }
    }
}
