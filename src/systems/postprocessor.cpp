#include "systems/postprocessor.h"
#include "components/postprocessor.h"
#include "components/collision.h"
#include "components/player.h"
#include "systems/collision.h"
#include "tween.h"
#include <glm/gtx/norm.hpp>


void PostProcessorSystem::update(float delta)
{
    if (delta <= 0.0f) return;
    for(auto [source, postprocessor, source_transform] : sp::ecs::Query<GlitchPostProcessor, sp::Transform>())
        updatePostProcessor(source, postprocessor, delta, source_transform, EffectType::Glitch);
    for(auto [source, postprocessor, source_transform] : sp::ecs::Query<WarpPostProcessor, sp::Transform>())
        updatePostProcessor(source, postprocessor, delta, source_transform, EffectType::Warp);
}

void PostProcessorSystem::updatePostProcessor(sp::ecs::Entity& source, PostProcessorComponent& postprocessor, float delta, sp::Transform source_transform, EffectType type)
{
    for(auto target : sp::CollisionSystem::queryArea(source_transform.getPosition() - glm::vec2(postprocessor.max_radius, postprocessor.max_radius), source_transform.getPosition() + glm::vec2(postprocessor.max_radius, postprocessor.max_radius)))
    {
        if (target == source) continue;
        auto player = target.getComponent<PlayerControl>();
        if (!player) continue;

        auto tt = target.getComponent<sp::Transform>();
        auto diff = source_transform.getPosition() - tt->getPosition();
        float dist2 = std::max(1.0f, glm::length2(diff));
        if (dist2 > postprocessor.max_radius*postprocessor.max_radius)
            continue;

        float alpha_strength = 0.0f;
        printf("max: %f\n", postprocessor.effect_strength);

        if (dist2 < postprocessor.min_radius*postprocessor.min_radius){
            // Inside of min_radius, use max strength effect
            alpha_strength = postprocessor.effect_strength;
        } else {
            // Outside of min_radius, scale effect by distance
            alpha_strength = Tween<float>::easeInQuartic(dist2, postprocessor.max_radius*postprocessor.max_radius, postprocessor.min_radius*postprocessor.min_radius, 0.0f, postprocessor.effect_strength );
        }

        switch (type){
            case EffectType::Glitch:
                player->glitch_alpha = std::max(player->glitch_alpha, alpha_strength);
                break;
            case EffectType::Warp:
                player->warp_alpha = std::max(player->warp_alpha, alpha_strength);
                break;
            default:
                break;
        }
    }
}
