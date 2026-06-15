#pragma once

#include "ecs/entity.h"
#include "components/faction.h"
#include <functional>

class TargetsContainer
{
public:
    enum ESelectionType
    {
        Targetable,
        Selectable,
        Scannable,
    };

    enum class KnownFriendOrFoe
    {
        Any,
        Known,
        Unknown,
        KnownFriendly,
        KnownNonFriendly,
        NotKnownFriendly,
        KnownNeutral,
        KnownNonNeutral,
        NotKnownNeutral,
        KnownHostile,
        KnownNonHostile,
        NotKnownHostile
    };

    TargetsContainer();

    void setAllowWaypointSelection() { allow_waypoint_selection = true; }

    void clear();
    void add(sp::ecs::Entity obj);
    void set(sp::ecs::Entity obj);
    void set(const std::vector<sp::ecs::Entity>& objs);
    std::vector<sp::ecs::Entity> getTargets();
    sp::ecs::Entity get();
    int getWaypointIndex();
    void setWaypointIndex(int index);

    void setToClosestTo(glm::vec2 position, float max_range, ESelectionType selection_type);

    // Select next/previous target by selection type, and optionally also by
    // friend-or-foe state.
    void setNext(glm::vec2 position, float max_range, ESelectionType selection_type, KnownFriendOrFoe known_fof = KnownFriendOrFoe::Any);
    void setPrev(glm::vec2 position, float max_range, ESelectionType selection_type, KnownFriendOrFoe known_fof = KnownFriendOrFoe::Any);
    // Select next/previous target by selection type and a function-defined
    // filter.
    void setNext(glm::vec2 position, float max_range, ESelectionType selection_type, std::function<bool(sp::ecs::Entity)> filter);
    void setPrev(glm::vec2 position, float max_range, ESelectionType selection_type, std::function<bool(sp::ecs::Entity)> filter);

private:
    std::vector<sp::ecs::Entity> entries;
    bool allow_waypoint_selection;
    int waypoint_selection_index;

    bool isFoFKnown(sp::ecs::Entity entity);
    void sortByDistance(glm::vec2 position, std::vector<sp::ecs::Entity>& entities);
    bool isValidTarget(sp::ecs::Entity entity, ESelectionType selection_type);
    // Return a vector of entities that match the given condition.
    std::vector<sp::ecs::Entity> populateEntities(glm::vec2 position, float max_range, ESelectionType selection_type, KnownFriendOrFoe known_fof);
    std::vector<sp::ecs::Entity> populateEntities(glm::vec2 position, float max_range, ESelectionType selection_type, std::function<bool(sp::ecs::Entity)> filter);
    void setNext(glm::vec2 position, const std::vector<sp::ecs::Entity>& entities);
    void setPrev(glm::vec2 position, const std::vector<sp::ecs::Entity>& entities);
};
