#include "systems/shieldsystem.h"

#include "components/shields.h"
#include "components/docking.h"
#include "components/reactor.h"
#include "components/scanning.h"
#include "ecs/query.h"
#include "playerInfo.h"
#include "tween.h"


void ShieldSystem::update(float delta)
{
    for(auto [entity, shields, reactor] : sp::ecs::Query<Shields, sp::ecs::optional<Reactor>>())
    {
        // If shields are calibrating, tick the calibration delay. Factor shield
        // subsystem effectiveness when determining the tick rate.
        if (shields.calibration_delay > 0.0f) {
            shields.calibration_delay -= delta * (shields.front_system.getSystemEffectiveness() * shields.rear_system.getSystemEffectiveness()) * 0.5f;
            shields.active = false;
        }
        if (shields.active && reactor) {
            // Consume power if shields are enabled.
            if (!reactor->useEnergy(delta * shields.energy_use_per_second))
                shields.active = false;
        }
        int n = 0;
        for(auto& shield : shields.entries)
        {
            if (shield.level < shield.max)
            {
                float rate = 0.3f;
                rate *= shields.getSystemForIndex(n).getSystemEffectiveness();

                auto port = entity.getComponent<DockingPort>();
                if (port && port->state == DockingPort::State::Docked && port->target)
                {
                    auto bay = port->target.getComponent<DockingBay>();
                    if (bay && (bay->flags & DockingBay::ChargeShield))
                        rate *= 4.0f;
                }

                shield.level = std::min(shield.max, shield.level + delta * rate);
            }
            if (shield.hit_effect > 0)
                shield.hit_effect -= delta;
            n++;
        }

    }
}

void ShieldSystem::renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, Shields& shields)
{
    if (!shields.active)
        return;
    auto scanstate = e.getComponent<ScanState>();
    bool show_levels = (!my_spaceship || my_spaceship == e || !scanstate || scanstate->getStateFor(my_spaceship) == ScanState::State::FullScan);
    float sprite_scale = scale * 300.0f * 1.5f / 32;
    if (auto trace = e.getComponent<RadarTrace>()) {
        auto size = trace->radius * scale * 2.0f;
        size = std::clamp(size, trace->min_size, trace->max_size);
        sprite_scale = size * 1.5f / 32;
    }
    else if (auto physics = e.getComponent<sp::Physics>()) {
        sprite_scale = scale * physics->getSize().x * 3.0f / 32;
    }

    if (shields.entries.size() == 1)
    {
        glm::u8vec4 color = glm::u8vec4(255, 255, 255, 64);
        if (show_levels)
        {
            float level = shields.entries[0].level / shields.entries[0].max;
            color = Tween<glm::u8vec4>::linear(level, 1.0f, 0.0f, glm::u8vec4(128, 128, 255, 128), glm::u8vec4(255, 0, 0, 64));
        }
        if (shields.entries[0].hit_effect > 0.0f)
        {
            color = Tween<glm::u8vec4>::linear(shields.entries[0].hit_effect, 0.0f, 1.0f, color, glm::u8vec4(255, 0, 0, 128));
        }
        renderer.drawSprite("shield_circle.png", screen_position, sprite_scale * 0.25f * 1.5f * 256.0f, color);
    }else if (shields.entries.size() > 1) {
        float direction = rotation;
        float arc = 360.0f / float(shields.entries.size());

        for(auto& shield : shields.entries)
        {
            glm::u8vec4 color = glm::u8vec4(255, 255, 255, 64);
            if (show_levels)
            {
                float level = shield.level / shield.max;
                color = Tween<glm::u8vec4>::linear(level, 1.0f, 0.0f, glm::u8vec4(128, 128, 255, 128), glm::u8vec4(255, 0, 0, 64));
            }
            if (shield.hit_effect > 0.0f)
            {
                color = Tween<glm::u8vec4>::linear(shield.hit_effect, 0.0f, 1.0f, color, glm::u8vec4(255, 0, 0, 128));
            }

            glm::vec2 delta_a = vec2FromAngle(direction - arc / 2.0f);
            glm::vec2 delta_b = vec2FromAngle(direction);
            glm::vec2 delta_c = vec2FromAngle(direction + arc / 2.0f);
            
            auto p0 = screen_position + delta_b * sprite_scale * 32.0f * 0.05f;
            renderer.drawTexturedQuad("shield_circle.png",
                p0,
                p0 + delta_a * sprite_scale * 32.0f * 1.5f,
                p0 + delta_b * sprite_scale * 32.0f * 1.5f,
                p0 + delta_c * sprite_scale * 32.0f * 1.5f,
                glm::vec2(0.5, 0.5),
                glm::vec2(0.5, 0.5) + delta_a * 0.5f,
                glm::vec2(0.5, 0.5) + delta_b * 0.5f,
                glm::vec2(0.5, 0.5) + delta_c * 0.5f,
                color);
            direction += arc;
        }
    }
}