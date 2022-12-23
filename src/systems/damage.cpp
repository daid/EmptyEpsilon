#include "systems/damage.h"
#include "systems/collision.h"
#include "components/collision.h"
#include "components/hull.h"
#include "components/shields.h"
#include "gameGlobalInfo.h"
#include <glm/geometric.hpp>
#include "random.h"

#include "spaceObjects/spaceObject.h"
#include "spaceObjects/explosionEffect.h"


void DamageSystem::damageArea(glm::vec2 position, float blast_range, float min_damage, float max_damage, const DamageInfo& info, float min_range)
{
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(blast_range, blast_range), position + glm::vec2(blast_range, blast_range)))
    {
        auto transform = entity.getComponent<sp::Transform>();
        if (!transform) continue;
        auto physics = entity.getComponent<sp::Physics>();
        if (!physics) continue;

        float dist = glm::length(position - transform->getPosition()) - physics->getSize().x - min_range;
        if (dist < 0) dist = 0;
        if (dist < blast_range - min_range)
        {
            applyDamage(entity, max_damage - (max_damage - min_damage) * dist / (blast_range - min_range), info);
        }
    }
}

void DamageSystem::applyDamage(sp::ecs::Entity entity, float amount, const DamageInfo& info)
{
    auto shields = entity.getComponent<Shields>();
    if (shields && shields->active) {
        auto transform = entity.getComponent<sp::Transform>();
        float angle = 0;
        if (transform) {
            angle = angleDifference(transform->getRotation(), vec2ToAngle(info.location - transform->getPosition()));
            if (angle < 0)
                angle += 360.0f;
        }
        float arc = 360.0f / float(shields->count);
        int shield_index = int((angle + arc / 2.0f) / arc);
        shield_index %= shields->count;
        auto& shield = shields->entry[shield_index];

        float frequency_damage_factor = 1.f;
        if (info.type == DamageType::Energy && gameGlobalInfo->use_beam_shield_frequencies)
        {
            frequency_damage_factor = frequencyVsFrequencyDamageFactor(info.frequency, shields->frequency);
        }

        //Shield damage reduction curve. Damage reduction gets slightly exponetial effective with power.
        // This also greatly reduces the ineffectiveness at low power situations.
        float shield_damage_factor = shields->getDamageFactor(shield_index);

        float shield_damage = amount * shield_damage_factor * frequency_damage_factor;
        amount -= shield.level;
        shield.level -= shield_damage;
        if (shield.level < 0)
        {
            shield.level = 0.0;
        } else {
            shield.hit_effect = 1.0;
        }
        if (amount < 0.0f)
        {
            amount = 0.0;
        }
    }

    if (amount > 0.0f)
    {
        takeHullDamage(entity, amount, info);
    }
}

void DamageSystem::takeHullDamage(sp::ecs::Entity entity, float amount, const DamageInfo& info)
{
    auto hull = entity.getComponent<Hull>();
    if (!hull)
        return;
    if (!(hull->damaged_by_flags & (1 << int(info.type))))
        return;

    // If taking non-EMP damage, light up the hull damage overlay.
    if (info.type != DamageType::EMP)
    {
        auto obj_ptr = entity.getComponent<SpaceObject*>();
        if (obj_ptr) {
            PlayerSpaceship* player = dynamic_cast<PlayerSpaceship*>(*obj_ptr);
            if (player)
                player->hull_damage_indicator = 1.5;
        }
    }

    if (gameGlobalInfo->use_system_damage && hull)
    {
        if (auto sys = ShipSystem::get(entity, info.system_target))
        {
            //Target specific system
            float system_damage = (amount / hull->max) * 2.0f;
            if (info.type == DamageType::Energy)
                system_damage *= 3.0f;   //Beam weapons do more system damage, as they penetrate the hull easier.
            sys->health -= system_damage;
            if (sys->health < -1.0f)
                sys->health = -1.0f;

            for(int n=0; n<2; n++)
            {
                auto random_system = ShipSystem::Type(irandom(0, ShipSystem::COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (amount / hull->max) * 1.0f;
                sys = ShipSystem::get(entity, random_system);
                if (sys) {
                    sys->health -= system_damage;
                    if (sys->health < -1.0f)
                        sys->health = -1.0f;
                }
            }

            if (info.type == DamageType::Energy)
                amount *= 0.02f;
            else
                amount *= 0.5f;
        }else{
            //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
            float system_damage = (amount / hull->max) * 3.0f;
            if (info.type == DamageType::Energy)
                system_damage *= 2.5f;   //Beam weapons do more system damage, as they penetrate the hull easier.

            auto random_system = ShipSystem::Type(irandom(0, ShipSystem::COUNT - 1));
            sys = ShipSystem::get(entity, random_system);
            if (sys) {
                sys->health -= system_damage;
                if (sys->health < -1.0f)
                    sys->health = -1.0f;
            }
        }
    }

    hull->current -= amount;
    if (hull->current <= 0.0f && !hull->allow_destruction)
    {
        hull->current = 1;
    }

    if (hull->current <= 0.0f)
    {
        destroyedByDamage(entity, info);
        return;
    }

    if (hull->on_taking_damage.isSet())
    {
        if (info.instigator)
        {
            hull->on_taking_damage.call<void>(entity, info.instigator);
        } else {
            hull->on_taking_damage.call<void>(entity);
        }
    }
}

void DamageSystem::destroyedByDamage(sp::ecs::Entity entity, const DamageInfo& info)
{
    if (auto transform = entity.getComponent<sp::Transform>()) {
        if (auto physics = entity.getComponent<sp::Physics>()) {
            ExplosionEffect* e = new ExplosionEffect();
            e->setSize(physics->getSize().x * 1.5f);
            e->setPosition(transform->getPosition());
            e->setRadarSignatureInfo(0.0, 0.4, 0.4);
        }
    }

    if (info.instigator)
    {
        float points = 0;

        auto hull = entity.getComponent<Hull>();
        if (hull)
            points += hull->max * 0.1f;

        auto shields = entity.getComponent<Shields>();
        if (shields) {
            for(int n=0; n<shields->count; n++)
            {
                points += shields->entry[n].max * 0.1f;
            }
            points /= shields->count;
        }
        
        if (Faction::getRelation(info.instigator, entity) == FactionRelation::Enemy)
            Faction::getInfo(info.instigator).reputation_points += points;
        else
            Faction::getInfo(info.instigator).reputation_points = std::max(Faction::getInfo(info.instigator).reputation_points - points, 0.0f);
    }

    auto hull = entity.getComponent<Hull>();
    if (hull->on_destruction.isSet())
    {
        if (info.instigator)
        {
            hull->on_destruction.call<void>(entity, info.instigator);
        } else {
            hull->on_destruction.call<void>(entity);
        }
    }

    //Finally, destroy the entity.
    auto obj_ptr = entity.getComponent<SpaceObject*>();
    if (obj_ptr)
        (*obj_ptr)->destroy();
}
