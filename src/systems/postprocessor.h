#pragma once

#include "ecs/system.h"
#include "ecs/query.h"
#include "components/postprocessor.h"
#include "components/collision.h"
#include "systems/collision.h"

enum class EffectType
{
    Glitch,
    Warp
};

class PostProcessorSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
private:
    void updatePostProcessor(sp::ecs::Entity& source, PostProcessorComponent& postprocessor, float delta, sp::Transform source_transform, EffectType type);
    
};
