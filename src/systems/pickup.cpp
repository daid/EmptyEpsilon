#include "systems/pickup.h"
#include "components/pickup.h"
#include "components/player.h"
#include "components/reactor.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

void PickupSystem::update(float delta)
{
    sp::CollisionSystem::addHandler(this);
}

void PickupSystem::collision(sp::ecs::Entity a, sp::ecs::Entity b, float force)
{
    if (!game_server) return;

    if (auto pc = a.getComponent<PickupCallback>()) {
        if (!pc->player || b.hasComponent<PlayerControl>()) {
            if (pc->callback)
                pc->callback.call<void>(a, b);
            if (auto reactor = b.getComponent<Reactor>()) {
                reactor->energy += pc->give_energy;
            }
            a.destroy();
        }
    }
    if (auto cc = a.getComponent<CollisionCallback>()) {
        if (!cc->player || b.hasComponent<PlayerControl>()) {
            cc->callback.call<void>(a, b);
        }
    }
}
