#include "targetsContainer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

TargetsContainer::TargetsContainer()
{
    route_index = -1;
    waypoint_selection_index = -1;
    allow_waypoint_selection = false;
}

void TargetsContainer::clear()
{
    waypoint_selection_index = -1;
    entries.clear();
}

void TargetsContainer::add(P<SpaceObject> obj)
{
    if (obj && !entries.has(obj))
        entries.push_back(obj);
}

void TargetsContainer::set(P<SpaceObject> obj)
{
    if (obj)
    {
        if (entries.size() > 0)
        {
            entries[0] = obj;
            if (entries.size() > 1)
                entries.resize(1);
        }else{
            entries.push_back(obj);
        }
    }
    else
    {
        clear();
    }
    waypoint_selection_index = -1;
}

void TargetsContainer::set(PVector<SpaceObject> objs)
{
    waypoint_selection_index = -1;
    entries = objs;
}

void TargetsContainer::setToClosestTo(sf::Vector2f position, float max_range, ESelectionType selection_type)
{
    P<SpaceObject> target;
    PVector<Collisionable> list = CollisionManager::queryArea(position - sf::Vector2f(max_range, max_range), position + sf::Vector2f(max_range, max_range));
    foreach(Collisionable, obj, list)
    {
        P<SpaceObject> spaceObject = obj;
        if (spaceObject && spaceObject != my_spaceship)
        {
            switch(selection_type)
            {
            case Selectable:
                if (!spaceObject->canBeSelectedBy(my_spaceship))
                    continue;
                break;
            case Targetable:
                if (!spaceObject->canBeTargetedBy(my_spaceship))
                    continue;
                break;
            }
            if (!target || sf::length(position - spaceObject->getPosition()) < sf::length(position - target->getPosition()))
                target = spaceObject;
        }
    }
    
    
    if (my_spaceship && allow_waypoint_selection)
    {
        if (route_index == -1){
            for(int n=0; n<PlayerSpaceship::max_waypoints; n++)
            {
                sf::Vector2f wp = my_spaceship->waypoints[n];
                if (wp < empty_waypoint && (wp - position) < max_range)
                {
                    if (!target || sf::length(position - wp) < sf::length(position - target->getPosition()))
                    {
                        clear();
                        waypoint_selection_index = n;
                        waypoint_selection_position = wp;
                        return;
                    }
                }
            }
        } else {
            for(int n=0; n<PlayerSpaceship::max_waypoints_in_route; n++)
            {
                sf::Vector2f wp = my_spaceship->routes[route_index][n];
                if (wp < empty_waypoint && (wp - position) < max_range)
                {
                    if (!target || sf::length(position - wp) < sf::length(position - target->getPosition()))
                    {
                        clear();
                        waypoint_selection_index = n;
                        waypoint_selection_position = wp;
                        return;
                    }
                }
            }
        }
    }
    set(target);
}

void TargetsContainer::nextWaypoint(bool forward){
    if (my_spaceship && allow_waypoint_selection) {
        if (route_index == -1){ // only sciense selects waypoints, no need to handle routes
            entries.clear();
            int current = getWaypointIndex();
            int next = -1;
            if (current == -1){
                if (forward){
                    next = 0;
                } else {
                    for(int n=PlayerSpaceship::max_waypoints-1; n >= 0 && next == -1; n--){
                        if (my_spaceship->waypoints[n] < empty_waypoint){
                            next = n;
                        }
                    }
                }
            } else {
                if (forward){
                    for(int n=current; n != current-1 && next == -1; n = (n + PlayerSpaceship::max_waypoints + 1) % PlayerSpaceship::max_waypoints){
                        if (my_spaceship->waypoints[n] < empty_waypoint){
                            next = n;
                        }
                    }
                } else {
                    for(int n=current; n != current+1 && next == -1; n = (n + PlayerSpaceship::max_waypoints - 1) % PlayerSpaceship::max_waypoints){
                        if (my_spaceship->waypoints[n] < empty_waypoint){
                            next = n;
                        }
                    }
                }
            }
            setWaypointIndex(next);
        }
    }
}

void TargetsContainer::next(PVector<SpaceObject> potentials, bool forward){
    P<SpaceObject> found = nullptr;
    bool current_reached = false;
    P<SpaceObject> lastSeen = nullptr; // for reverse logic edge case
    P<SpaceObject> firstSeen = nullptr; // for forward logic edge case
    foreach(SpaceObject, obj, potentials) {
        if (found) // no need to iterate more
            break;
        if (!obj) // should never happen but helps debug confidence
            continue;
        if(!firstSeen)
            firstSeen = obj;
        if (obj == get()) { // reached current target
            current_reached = true;
            if (!forward && lastSeen){
                found = lastSeen;
            }
        } else if (forward && current_reached) { // 1 after current
            found = obj;
        } 
        lastSeen = obj;
    } // end of loop
    /*
    LOG(INFO) << "size : " << string(potentials.size(),0);
    LOG(INFO) << "found : " << (found ? found->getCallSign() : "NULL");
    LOG(INFO) << "firstSeen : " << (firstSeen ? firstSeen->getCallSign() : "NULL");
    LOG(INFO) << "lastSeen : " << (lastSeen ? lastSeen->getCallSign() : "NULL");
    */
    if (!found){
        // current target might be the first or last element
        found = forward? firstSeen : lastSeen;
    } 
    set(found);
}

int TargetsContainer::getWaypointIndex()
{
    if (!my_spaceship || waypoint_selection_index < 0)
        waypoint_selection_index = -1;
    else if (route_index == -1){
        if (waypoint_selection_index >= PlayerSpaceship::max_waypoints)
            waypoint_selection_index = -1;
        else if (my_spaceship->waypoints[waypoint_selection_index] >= empty_waypoint)
            waypoint_selection_index = -1;
        else if (my_spaceship->waypoints[waypoint_selection_index] != waypoint_selection_position)
            waypoint_selection_index = -1;
    } else {
        if (waypoint_selection_index >= PlayerSpaceship::max_waypoints_in_route)
            waypoint_selection_index = -1;
        else if (my_spaceship->routes[route_index][waypoint_selection_index] >= empty_waypoint)
            waypoint_selection_index = -1;
        else if (my_spaceship->routes[route_index][waypoint_selection_index] != waypoint_selection_position)
            waypoint_selection_index = -1;
    }
    return waypoint_selection_index;
}

int TargetsContainer::getRouteIndex(){
    return route_index;
}

void TargetsContainer::setRouteIndex(int index){
    if (index < PlayerSpaceship::max_routes && index >= -1){
        route_index = index;
    }
    waypoint_selection_index = -1;
}

void TargetsContainer::setWaypointIndex(int index)
{
    waypoint_selection_index = index;
    if (route_index == -1){
        if (my_spaceship && index >= 0 && index < PlayerSpaceship::max_waypoints && my_spaceship->waypoints[index] < empty_waypoint)
            waypoint_selection_position = my_spaceship->waypoints[index];
    } else {
        if (my_spaceship && index >= 0 && index < PlayerSpaceship::max_waypoints_in_route && my_spaceship->routes[route_index][index] < empty_waypoint)
            waypoint_selection_position = my_spaceship->routes[route_index][index];
    }
}

sf::Vector2f TargetsContainer::getWaypointPosition()
{
    if (my_spaceship && waypoint_selection_index >= 0)
        return waypoint_selection_position;
    else 
        return sf::Vector2f();
}
