#include "components/faction.h"
#include "ecs/query.h"


static FactionInfo default_faction_info;


sp::ecs::Entity Faction::find(const string& name)
{
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>()) {
        if (info.name == name)
            return entity;
    }
    return {};
}

FactionInfo& Faction::getInfo(sp::ecs::Entity entity)
{
    auto faction = entity.getComponent<Faction>();
    if (faction) {
        auto info = faction->entity.getComponent<FactionInfo>();
        if (info)
            return *info;
    }
    return default_faction_info;
}

FactionRelation Faction::getRelation(sp::ecs::Entity a, sp::ecs::Entity b)
{
    auto fia = Faction::getInfo(a);
    auto fb = b.getComponent<Faction>();
    if (fb)
        return fia.getRelation(fb->entity);
    return fia.getRelation({});
}

// TODO: Info about multiple components belongs in systems, not in component code.
#include "components/target.h"
#include "components/scanning.h"

void Faction::didAnOffensiveAction(sp::ecs::Entity entity)
{
    //We did an offensive action towards our target.
    // Check for each faction. If this faction knows if the target is an enemy or a friendly, it now knows if this object is an enemy or a friendly.
    auto scanstate = entity.getComponent<ScanState>();
    if (!scanstate) return;
    auto target = entity.getComponent<Target>();
    if (!target || !target->entity) return;
    auto target_scan_state = target->entity.getComponent<ScanState>();
    auto target_faction = target->entity.getComponent<Faction>();

    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if ((!target_scan_state || target_scan_state->getStateForFaction(faction_entity) != ScanState::State::NotScanned) || (target_faction && target_faction->entity == faction_entity)) {
            // This faction knows if the target is friendly or enemy, so check if we need to set it to FFI
            if (scanstate->getStateForFaction(faction_entity) == ScanState::State::NotScanned) {
                scanstate->setStateForFaction(faction_entity, ScanState::State::FriendOrFoeIdentified);
            }
        }
    }
}

FactionRelation FactionInfo::getRelation(sp::ecs::Entity faction_entity)
{
    // If the entity has no faction, return None
    if (!faction_entity)
        return FactionRelation::None;

    for(auto it : relations)
        if (it.other_faction == faction_entity)
            return it.relation;
    return FactionRelation::Neutral;
}

void FactionInfo::setRelation(sp::ecs::Entity faction_entity, FactionRelation relation)
{
    for(auto& it : relations) {
        if (it.other_faction == faction_entity) {
            it.relation = relation;
            relations_dirty = true;
            return;
        }
    }
    relations.push_back({faction_entity, relation});
    relations_dirty = true;
}

FactionInfo* FactionInfo::find(const string& name)
{
    return Faction::find(name).getComponent<FactionInfo>();
}
