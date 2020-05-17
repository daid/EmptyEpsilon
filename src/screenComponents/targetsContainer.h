#ifndef TARGETS_CONTAINER_H
#define TARGETS_CONTAINER_H

#include "spaceObjects/spaceObject.h"

class TargetsContainer
{
private:
    PVector<SpaceObject> entries;
    bool allow_waypoint_selection;
    int route_index;
    int waypoint_selection_index;
    sf::Vector2f waypoint_selection_position;
public:
    enum ESelectionType
    {
        Targetable,
        Selectable
    };
    
    TargetsContainer();
    
    void setAllowWaypointSelection() { allow_waypoint_selection = true; }

    void clear();
    void add(P<SpaceObject> obj);
    void set(P<SpaceObject> obj);
    void set(PVector<SpaceObject> objs);
    PVector<SpaceObject> getTargets() { entries.update(); return entries; }
    P<SpaceObject> get() { entries.update(); if (entries.size() > 0) return entries[0]; return nullptr; }
    int getWaypointIndex();
    void setWaypointIndex(int index);
    void setRouteIndex(int index);
    int getRouteIndex();
    sf::Vector2f getWaypointPosition();
    
    void setToClosestTo(sf::Vector2f position, float max_range, ESelectionType selection_type);
    void next(PVector<SpaceObject> potentials, bool forward);
    void nextWaypoint(bool forward);
};

#endif//TARGETS_CONTAINER_H
