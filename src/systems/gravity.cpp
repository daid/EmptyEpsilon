#include "systems/gravity.h"
#include "components/gravity.h"
#include "components/collision.h"
#include "components/player.h"
#include "components/hull.h"
#include "systems/collision.h"
#include "systems/damage.h"
#include "multiplayer_server.h"
#include "ecs/query.h"
#include "random.h"
#include "menus/luaConsole.h"
#include <glm/gtx/norm.hpp>


void GravitySystem::update(float delta)
{
    static constexpr float max_force = 10000.0f;
    static constexpr float wormhole_target_spread = 500.0f;
    static constexpr float max_gravity_alpha = 2.0f;
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

            auto player = target.getComponent<PlayerControl>();
            if (player)
            {
                player->in_gravity = (1 - (dist2 / (grav.range * grav.range)));
                if (grav.visual_effect)
                {
                    // Apply glitch effect that gets stronger the closer to the center of the gravity system
                    player->gravity_alpha = ((1 - (dist2 / (grav.range * grav.range))) * max_gravity_alpha);
                }

            }


            if (grav.wormhole_target.x || grav.wormhole_target.y) {
                if (force >= max_force)
                {
                    if (game_server) {
                        tt->setPosition( (grav.wormhole_target + glm::vec2(random(-wormhole_target_spread, wormhole_target_spread), random(-wormhole_target_spread, wormhole_target_spread))));
                        if (grav.on_teleportation)
                        {
                            LuaConsole::checkResult(grav.on_teleportation.call<void>(source, target));
                            continue; //callback could destroy the entity, so do no extra processing.
                        }
                        if (player)
                            // set just_teleported for use by hardware
                            player->just_teleported = 2.0f;
                            player->in_gravity = 0.0f;
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
                        if (!target.hasComponent<Hull>() || target.getComponent<Hull>()->allow_destruction)
                            target.destroy();
                        return;
                    }
                }
                if (force > 100.0f)
                    DamageSystem::applyDamage(target, force * delta / 10.0f, info);
            }
        }
    }
}

void GravitySystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Gravity& component)
{
    // womrhole_target isn't replicated, so show only on the server.
    if (game_server && (component.wormhole_target.x != 0.0f || component.wormhole_target.y != 0.0f))
    {
        if (auto transform = e.getComponent<sp::Transform>())
            renderer.drawLine(screen_position, screen_position + (component.wormhole_target - transform->getPosition()) * scale, glm::u8vec4(255, 255, 255, 32));
    }
    renderer.drawCircleOutline(screen_position, component.range * scale, 2.0, glm::u8vec4(255, 255, 255, 32));
}
