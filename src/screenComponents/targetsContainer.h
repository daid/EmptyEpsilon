#ifndef TARGETS_CONTAINER_H
#define TARGETS_CONTAINER_H

#include "ecs/entity.h"
#include "components/faction.h"

class TargetsContainer
{
public:
    enum ESelectionType
    {
        Targetable,
        Selectable,
        Scannable,
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
    void setNext(glm::vec2 position, float max_range, ESelectionType selection_type);
    void setNext(glm::vec2 position, float max_range, ESelectionType selection_type, FactionRelation relation);

private:
    std::vector<sp::ecs::Entity> entries;
    bool allow_waypoint_selection;
    int waypoint_selection_index;
    glm::vec2 waypoint_selection_position{};

    void setNext(glm::vec2 position, float max_range, std::vector<sp::ecs::Entity>& entities);
    void sortByDistance(glm::vec2 position, std::vector<sp::ecs::Entity>& entities);
    bool isValidTarget(sp::ecs::Entity entity, ESelectionType selection_type);
};

#endif//TARGETS_CONTAINER_H
