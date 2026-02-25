#include "systems/player.h"
#include "components/player.h"
#include "ecs/query.h"

void PlayerSystem::update(float delta)
{
    if (delta <= 0.0f) return;
    for(auto [entity, player] : sp::ecs::Query<PlayerControl>())
    {
        // Decrease wormhole visual effects
        if (player.gravity_alpha > 0.0f)
            player.gravity_alpha -= delta;

        // Decrease post-wormhole teleport
        if (player.just_teleported > 0.0f)
            player.just_teleported -= delta;
    }
}
