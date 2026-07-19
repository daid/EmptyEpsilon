#include "components/scanning.h"
#include "components/faction.h"


ScanState::State ScanState::getStateFor(sp::ecs::Entity entity)
{
    auto faction = entity.getComponent<Faction>();
    return getStateForFaction(faction ? faction->entity : sp::ecs::Entity{});
}

void ScanState::setStateFor(sp::ecs::Entity entity, ScanState::State state)
{
    auto faction = entity.getComponent<Faction>();
    setStateForFaction(faction ? faction->entity : sp::ecs::Entity{}, state);
}

ScanState::State ScanState::getStateForFaction(sp::ecs::Entity faction_entity)
{
    for(const auto& it : per_faction)
        if (it.faction == faction_entity)
            return it.state;
    return ScanState::State::NotScanned;
}

void ScanState::setStateForFaction(sp::ecs::Entity faction_entity, ScanState::State state)
{
    for(auto& it : per_faction) {
        if (it.faction == faction_entity) {
            it.state = state;
            per_faction_dirty = true;
            return;
        }
    }
    per_faction.push_back({faction_entity, state});
    per_faction_dirty = true;
}
