#include "systems/lifetimesystem.h"


#include "components/missile.h"
#include "components/lifetime.h"
#include "ecs/query.h"
#include "multiplayer_server.h"
#include "systems/missilesystem.h"

void LifeTimeSystem::update(float delta)
{
    if (game_server) {
        // TODO: Not really part of missile
        for(auto [entity, lifetime] : sp::ecs::Query<LifeTime>()) {
            lifetime.alive_for += delta;
            if (lifetime.alive_for >= lifetime.maximum) {
                if (entity.hasComponent<ExplodeOnTimeout>() and entity.hasComponent<MissileSystem>()) {
                    if (auto eot = entity.getComponent<ExplodeOnTouch>()) {
                        if (auto missilesystem = entity.getComponent<MissileSystem>()){
                            missilesystem->explode(entity, {}, *eot);
                        }
                    }
                }
                entity.destroy();
            }
        }
    }
}
