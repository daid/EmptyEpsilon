#include "systems/sfx.h"
#include "components/sfx.h"
#include "components/collision.h"
#include "ecs/query.h"
#include "soundManager.h"


void SfxSystem::update(float delta)
{
    for(auto [entity, sfx, transform] : sp::ecs::Query<Sfx, sp::ecs::optional<sp::Transform>>()) {
        if (sfx.played) continue;
        sfx.played = true;

        if (transform)
            soundManager->playSound(sfx.sound, transform->getPosition(), 400.0, 0.6, sfx.pitch, sfx.volume);
        else
            soundManager->playSound(sfx.sound, sfx.pitch, sfx.volume);
    }
}
