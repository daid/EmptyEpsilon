#include "systems/gravity.h"
#include "components/gravity.h"
#include "components/collision.h"
#include "systems/collision.h"
#include "systems/damage.h"
#include "multiplayer_server.h"
#include "ecs/query.h"
#include "random.h"
#include <glm/gtx/norm.hpp>


void GravitySystem::update(float delta)
{
    static constexpr float max_force = 10000.0f;
    static constexpr float wormhole_target_spread = 500.0f;
    if (delta <= 0.0f) return;

    for(auto [source, grav, source_transform] : sp::ecs::Query<Gravity, sp::Transform>()) {
        for(auto target : sp::CollisionSystem::queryArea(source_transform.getPosition() - glm::vec2(grav.range, grav.range), source_transform.getPosition() + glm::vec2(grav.range, grav.range))) {
            if (target == source) continue;
            auto tt = target.getComponent<sp::Transform>();
            auto diff = source_transform.getPosition() - tt->getPosition();
            float dist2 = std::max(1.0f, glm::length2(diff));
            if (dist2 > grav.range*grav.range)
                continue;
            float force = (grav.range * grav.range * grav.force) / dist2;
            if (force >= max_force)
                force = max_force;
            tt->setPosition(tt->getPosition() + diff / std::sqrt(dist2) * delta * force);

            if (grav.wormhole_target.x || grav.wormhole_target.y) {
                /*TODO
                // Warp postprocessor-alpha is calculated using alpha = (1 - (delay/10))
                if (spaceship)
                    spaceship->wormhole_alpha = ((distance / grav.range) * ALPHA_MULTIPLIER);
                */

                if (force >= max_force)
                {
                    if (game_server) {
                        tt->setPosition( (grav.wormhole_target + glm::vec2(random(-wormhole_target_spread, wormhole_target_spread), random(-wormhole_target_spread, wormhole_target_spread))));
                        if (grav.on_teleportation.isSet())
                        {
                            grav.on_teleportation.call<void>(source, target);
                            continue; //callback could destroy the entity, so do no extra processing.
                        }
                        //if (spaceship)
                        //    spaceship->wormhole_alpha = 0.0;
                    }
                }
            }

            // Damage at center
            if (grav.damage && game_server) {
                DamageInfo info({}, DamageType::Kinetic, source_transform.getPosition());
                if (force >= max_force)
                {
                    DamageSystem::applyDamage(target, 100000.0, info); //try to destroy the object by inflicting a huge amount of damage
                    if (target)
                    {
                        target.destroy(); // TODO: This might destroy things that should be never be destroyed in a LARP.
                        return;
                    }
                }
                if (force > 100.0f)
                    DamageSystem::applyDamage(target, force * delta / 10.0f, info);
            }
        }
    }
}
