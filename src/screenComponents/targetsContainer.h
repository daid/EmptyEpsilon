#ifndef TARGETS_CONTAINER_H
#define TARGETS_CONTAINER_H

#include "spaceObjects/spaceObject.h"

class TargetsContainer
{
private:
    std::vector<sp::ecs::Entity> entries;
    bool allow_waypoint_selection;
    int waypoint_selection_index;
    glm::vec2 waypoint_selection_position{};
public:
    enum ESelectionType
    {
        Targetable,
        Selectable
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
    void setNext(float max_range, ESelectionType selection_type);
    void setNext(float max_range, ESelectionType selection_type, FactionRelation relation);
};

#endif//TARGETS_CONTAINER_H
