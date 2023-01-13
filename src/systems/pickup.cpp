#include "systems/pickup.h"
#include "components/pickup.h"
#include "components/player.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

void PickupSystem::update(float delta)
{
}

void PickupSystem::collision(sp::ecs::Entity a, sp::ecs::Entity b, float force)
{
    if (!game_server) return;

    if (auto pc = a.getComponent<PickupCallback>()) {
        if (pc->callback.isSet())
            pc->callback.call<void>(a, b);
        a.destroy();
    }
    if (auto cc = a.getComponent<CollisionCallback>()) {
        if (!cc->player || b.hasComponent<PlayerControl>()) {
            cc->callback.call<void>(a, b);
        }
    }
}
