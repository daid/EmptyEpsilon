#include "systems/pickup.h"
#include "components/pickup.h"
#include "components/player.h"
#include "components/reactor.h"
#include "components/missiletubes.h"
#include "ecs/query.h"
#include "multiplayer_server.h"

PickupSystem::PickupSystem() {
    sp::CollisionSystem::addHandler(this);
}

void PickupSystem::update(float delta)
{
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
            if (auto tubes = b.getComponent<MissileTubes>()) {
                for(int n=0; n<MW_Count; n++)
                    tubes->storage[n] = std::min(tubes->storage[n] + pc->give_missile[n], tubes->storage_max[n]);
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
