#include "systems/player.h"
#include "components/player.h"
#include "ecs/query.h"

void PlayerSystem::update(float delta)
{
    if (delta <= 0.0f) return;
    for(auto [entity, player] : sp::ecs::Query<PlayerControl>())
    {
        // Decrease glitch postprocessor visual effects
        if (player.glitch_alpha > 0.0f)
            player.glitch_alpha -= delta * player.glitch_alpha_decay_rate;

        // Decrease warp postprocessor visual effects
        if (player.warp_alpha > 0.0f)
            player.warp_alpha -= delta * player.warp_alpha_decay_rate;

        // Decrease post-wormhole teleport
        if (player.just_teleported > 0.0f)
            player.just_teleported -= delta;
    }
}
