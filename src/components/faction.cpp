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
