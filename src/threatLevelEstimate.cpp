#include "gameGlobalInfo.h"
#include "threatLevelEstimate.h"
#include "ecs/query.h"
#include "components/hull.h"
#include "components/collision.h"
#include "components/shields.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/missile.h"
#include "components/player.h"
#include "systems/collision.h"


ThreatLevelEstimate::ThreatLevelEstimate()
{
    smoothed_threat_level = 0.0;
    threat_high = false;
    threat_high_func = nullptr;
    threat_low_func = nullptr;
}

void ThreatLevelEstimate::update(float delta)
{
    if (!gameGlobalInfo)
        return;

    float max_threat = 0.0f;
    for(auto [entity, pc] : sp::ecs::Query<PlayerControl>())
        max_threat = std::max(max_threat, getThreatFor(entity));
    float f = delta / threat_drop_off_time;
    smoothed_threat_level = ((1.0f - f) * smoothed_threat_level) + (max_threat * f);

    if (!threat_high && smoothed_threat_level > threat_high_level)
    {
        threat_high = true;
        if (threat_high_func)
            threat_high_func();
    }

    if (threat_high && smoothed_threat_level < threat_low_level)
    {
        threat_high = false;
        if (threat_low_func)
            threat_low_func();
    }
}

float ThreatLevelEstimate::getThreatFor(sp::ecs::Entity ship)
{
    if (!ship)
        return 0.0;

    float threat = 0.0;

    auto hull = ship.getComponent<Hull>();
    if (hull)
        threat += hull->max - hull->current;
    auto shields = ship.getComponent<Shields>();
    if (shields) {
        if (shields->active)
            threat += 200;
        for(auto& shield : shields->entries)
            threat += shield.max - shield.level;
    }

    float radius = 7000.0;
    
    auto transform = ship.getComponent<sp::Transform>();
    if (transform) {
        auto ship_position = transform->getPosition();
        for(auto entity : sp::CollisionSystem::queryArea(ship_position - glm::vec2(radius, radius), ship_position + glm::vec2(radius, radius)))
        {
            bool is_shiplike = entity.hasComponent<BeamWeaponSys>() || entity.hasComponent<MissileTubes>();
            if (!is_shiplike || Faction::getRelation(ship, entity) == FactionRelation::Enemy)
            {
                if (entity.hasComponent<MissileFlight>() && entity.hasComponent<ExplodeOnTouch>())
                    threat += 5000.0f;
                if (entity.hasComponent<BeamEffect>())
                    threat += 5000.0f;
                continue;
            }

            bool is_being_attacked = false;
            hull = entity.getComponent<Hull>();
            float score = 200.0f;
            if (hull)
                score += hull->max;
            auto shields = entity.getComponent<Shields>();
            if (shields) {
                for(auto& shield : shields->entries) {
                    score += shield.max * 2.0f / float(shields->entries.size());
                    if (shield.hit_effect > 0.0f)
                        is_being_attacked = true;
                }
            }
            if (is_being_attacked)
                score += 500.0f;

            threat += score;
        }
    }

    return threat;
}

void ThreatLevelEstimate::setCallbacks(func_t low, func_t high)
{
    threat_low_func = low;
    threat_high_func = high;

    if (threat_high)
    {
        if (threat_high_func)
            threat_high_func();
    }else{
        if (threat_low_func)
            threat_low_func();
    }
}
