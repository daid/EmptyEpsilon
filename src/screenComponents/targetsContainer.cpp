#include "targetsContainer.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "systems/collision.h"


TargetsContainer::TargetsContainer()
{
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

void TargetsContainer::setToClosestTo(glm::vec2 position, float max_range, ESelectionType selection_type)
{
    P<SpaceObject> target;
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(max_range, max_range), position + glm::vec2(max_range, max_range)))
    {
        auto ptr = entity.getComponent<SpaceObject*>();
        if (!ptr || !*ptr) continue;
        P<SpaceObject> spaceObject = *ptr;
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
            if (!target || glm::length2(position - spaceObject->getPosition()) < glm::length2(position - target->getPosition()))
                target = spaceObject;
        }
    }


    if (my_spaceship && allow_waypoint_selection)
    {
        for(int n=0; n<my_spaceship->getWaypointCount(); n++)
        {
            if (glm::length2(my_spaceship->waypoints[n] - position) < max_range*max_range)
            {
                if (!target || glm::length2(position - my_spaceship->waypoints[n]) < glm::length2(position - target->getPosition()))
                {
                    clear();
                    waypoint_selection_index = n;
                    waypoint_selection_position = my_spaceship->waypoints[n];
                    return;
                }
            }
        }
    }
    set(target);
}

int TargetsContainer::getWaypointIndex()
{
    if (!my_spaceship || waypoint_selection_index < 0)
        waypoint_selection_index = -1;
    else if (waypoint_selection_index >= my_spaceship->getWaypointCount())
        waypoint_selection_index = -1;
    else if (my_spaceship->waypoints[waypoint_selection_index] != waypoint_selection_position)
        waypoint_selection_index = -1;
    return waypoint_selection_index;
}

void TargetsContainer::setWaypointIndex(int index)
{
    waypoint_selection_index = index;
    if (my_spaceship && index >= 0 && index < (int)my_spaceship->waypoints.size())
        waypoint_selection_position = my_spaceship->waypoints[index];
}
