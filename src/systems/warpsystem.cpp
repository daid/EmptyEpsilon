#include "systems/warpsystem.h"
#include "components/docking.h"
#include "components/collision.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/reactor.h"
#include "components/shields.h"
#include "components/faction.h"
#include "ecs/query.h"
#include "playerInfo.h"


void WarpSystem::update(float delta)
{
    for(auto [entity, warp, impulse, position, physics] : sp::ecs::Query<WarpDrive, sp::ecs::optional<ImpulseEngine>, sp::Transform, sp::Physics>())
    {
        if (warp.request > 0 || warp.current > 0)
        {
            if (isWarpJammed(entity))
                warp.request = 0;
        }
        if (warp.request > 0 || warp.current > 0)
        {
            if (impulse) {
                impulse->request = 1.0;
            }

            if (!impulse || impulse->actual >= 1.0f) {
                if (warp.current < warp.request)
                {
                    warp.current += delta / warp.charge_time;
                    if (warp.current > warp.request)
                        warp.current = warp.request;
                }else if (warp.current > warp.request)
                {
                    warp.current -= delta / warp.decharge_time;
                    if (warp.current < warp.request)
                        warp.current = warp.request;
                }
            }

            auto reactor = entity.getComponent<Reactor>();
            if (reactor) {
                // If warping, consume energy at a rate of 120% the warp request.
                // If shields are up, that rate is increased by an additional 50%.
                auto energy_use = warp.energy_warp_per_second * delta * warp.getSystemEffectiveness() * powf(warp.current, 1.3f);
                auto shields = entity.getComponent<Shields>();
                if (shields && shields->active)
                    energy_use *= 1.7f;
                if (!reactor->useEnergy(energy_use))
                    warp.request = 0;
            }
        }

        // Add heat based on warp factor.
        warp.addHeat(warp.current * delta * warp.heat_per_warp * warp.getSystemEffectiveness());

        // Determine forward direction and velocity.
        auto forward = vec2FromAngle(position.getRotation());
        auto current_velocity = physics.getVelocity();
        if (!impulse)
            current_velocity = glm::vec2{0, 0};
        physics.setVelocity(current_velocity + forward * (warp.current * warp.speed_per_level * warp.getSystemEffectiveness()));
    }
}

void WarpSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, WarpJammer& component)
{
    auto color = glm::u8vec4(200, 150, 100, 64);
    if (my_spaceship && Faction::getRelation(my_spaceship, e) == FactionRelation::Enemy)
        color = glm::u8vec4(255, 0, 0, 64);
    renderer.drawCircleOutline(screen_position, component.range*scale, 2.0, color);
}

bool WarpSystem::isWarpJammed(sp::ecs::Entity entity)
{
    if (auto transform = entity.getComponent<sp::Transform>()) {
        auto position = transform->getPosition();
        for(auto [entity, jammer, jt] : sp::ecs::Query<WarpJammer, sp::Transform>())
        {
            if (glm::length2(jt.getPosition() - position) < jammer.range * jammer.range)
                return true;
        }
    }
    return false;
}

glm::vec2 WarpSystem::getFirstNoneJammedPosition(glm::vec2 start, glm::vec2 end)
{
    auto startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    sp::ecs::Entity first_jammer;
    float first_jammer_f = startEndLength;
    glm::vec2 first_jammer_q{0, 0};
    for(auto [entity, jammer, jt] : sp::ecs::Query<WarpJammer, sp::Transform>())
    {
        float f_inf = glm::dot(startEndDiff, jt.getPosition() - start) / startEndLength;
	    float f_limited = std::min(std::max(0.0f, f_inf), startEndLength);
        glm::vec2 q_limited = start + startEndDiff / startEndLength * f_limited;
        if (glm::length2(q_limited - jt.getPosition()) < jammer.range*jammer.range)
        {
            if (!first_jammer || f_limited < first_jammer_f)
            {
                first_jammer = entity;
                first_jammer_f = f_limited;
                first_jammer_q = start + startEndDiff / startEndLength * f_inf;
            }
        }
    }
    if (!first_jammer)
        return end;

    auto jt = first_jammer.getComponent<sp::Transform>();
    auto jammer = first_jammer.getComponent<WarpJammer>();
    float d = glm::length(first_jammer_q - jt->getPosition());
    return first_jammer_q + glm::normalize(start - end) * std::sqrt(jammer->range * jammer->range - d * d);
}