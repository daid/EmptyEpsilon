#include "systems/ai.h"
#include "components/ai.h"
#include "ecs/query.h"
#include "multiplayer_server.h"
#include "ai/ai.h"
#include "ai/aiFactory.h"


void AISystem::update(float delta)
{
    if (delta <= 0.0f) return;
    if (!game_server)
        return;

    for(auto [entity, ai] : sp::ecs::Query<AIController>()) {
        if (ai.new_name.length() && (!ai.ai || ai.ai->canSwitchAI()))
        {
            auto f = ShipAIFactory::getAIFactory(ai.new_name);
            ai.ai = nullptr;
            if (f)
                ai.ai = f(entity);
            ai.new_name = "";
        }
        if (ai.ai)
            ai.ai->run(delta);
    }
}
