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

    for(auto [faction_entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if (scanstate->getStateFor(entity) == ScanState::State::NotScanned)
        {
            if (!target_scan_state || target_scan_state->getStateFor(entity) != ScanState::State::NotScanned)
                scanstate->setStateFor(entity, ScanState::State::FriendOrFoeIdentified);
        }
    }
}

FactionRelation FactionInfo::getRelation(sp::ecs::Entity faction_entity)
{
    for(auto it : relations)
        if (it.first == faction_entity)
            return it.second;
    return FactionRelation::Neutral;
}

void FactionInfo::setRelation(sp::ecs::Entity faction_entity, FactionRelation relation)
{
    for(auto& it : relations) {
        if (it.first == faction_entity) {
            it.second = relation;
            return;
        }
    }
    relations.push_back({faction_entity, relation});
}

FactionInfo* FactionInfo::find(const string& name)
{
    return Faction::find(name).getComponent<FactionInfo>();
}
