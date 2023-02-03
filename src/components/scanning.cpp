#include "components/scanning.h"
#include "components/faction.h"


ScanState::State ScanState::getStateFor(sp::ecs::Entity entity)
{
    auto faction = entity.getComponent<Faction>();
    auto f = faction ? faction->entity : sp::ecs::Entity{};
    for(const auto& it : per_faction)
        if (it.first == f)
            return it.second;
    return ScanState::State::NotScanned;
}

void ScanState::setStateFor(sp::ecs::Entity entity, ScanState::State state)
{
    auto faction = entity.getComponent<Faction>();
    auto f = faction ? faction->entity : sp::ecs::Entity{};
    for(auto& it : per_faction) {
        if (it.first == f) {
            it.second = state;
            return;
        }
    }
    per_faction.push_back({f, state});
}
