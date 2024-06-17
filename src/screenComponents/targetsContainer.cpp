#include "targetsContainer.h"
#include "playerInfo.h"
#include "systems/collision.h"
#include "components/hull.h"
#include "components/collision.h"
#include "components/scanning.h"
#include "components/radar.h"


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

void TargetsContainer::add(sp::ecs::Entity obj)
{
    if (!obj)
        return;
    for(auto e : entries)
        if (e == obj)
            return;
    entries.push_back(obj);
}

void TargetsContainer::set(sp::ecs::Entity obj)
{
    if (obj)
    {
        entries = {obj};
    }
    else
    {
        clear();
    }
    waypoint_selection_index = -1;
}

void TargetsContainer::set(const std::vector<sp::ecs::Entity>& objs)
{
    waypoint_selection_index = -1;
    entries = objs;
}

std::vector<sp::ecs::Entity> TargetsContainer::getTargets()
{
    return entries;
}

sp::ecs::Entity TargetsContainer::get()
{
    if (entries.empty())
        return {};
    return entries[0];
}

void TargetsContainer::setToClosestTo(glm::vec2 position, float max_range, ESelectionType selection_type)
{
    sp::ecs::Entity target;
    glm::vec2 target_position;
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(max_range, max_range), position + glm::vec2(max_range, max_range)))
    {
        auto transform = entity.getComponent<sp::Transform>();
        if (!transform) continue;
        if (!isValidTarget(entity, selection_type)) continue;
        
        if (!target || glm::length2(position - transform->getPosition()) < glm::length2(position - target_position)) {
            target = entity;
            target_position = transform->getPosition();
        }
    }


    if (allow_waypoint_selection)
    {
        if (auto lrr = my_spaceship.getComponent<LongRangeRadar>()) {
            for(size_t n=0; n<lrr->waypoints.size(); n++)
            {
                if (glm::length2(lrr->waypoints[n] - position) < max_range*max_range)
                {
                    if (!target || glm::length2(position - lrr->waypoints[n]) < glm::length2(position - target_position))
                    {
                        clear();
                        waypoint_selection_index = n;
                        waypoint_selection_position = lrr->waypoints[n];
                        return;
                    }
                }
            }
        }
    }
    set(target);
}

int TargetsContainer::getWaypointIndex()
{
    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    if (!lrr || waypoint_selection_index < 0 || waypoint_selection_index >= int(lrr->waypoints.size()))
        waypoint_selection_index = -1;
    else if (lrr->waypoints[waypoint_selection_index] != waypoint_selection_position)
        waypoint_selection_index = -1;
    return waypoint_selection_index;
}

void TargetsContainer::setWaypointIndex(int index)
{
    auto lrr = my_spaceship.getComponent<LongRangeRadar>();
    waypoint_selection_index = index;
    if (lrr && index >= 0 && index < (int)lrr->waypoints.size())
        waypoint_selection_position = lrr->waypoints[index];
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type)
{
    //TODO
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type, FactionRelation relation)
{
    //TODO
}

bool TargetsContainer::isValidTarget(sp::ecs::Entity entity, ESelectionType selection_type)
{
    if (entity == my_spaceship) return false;

    switch(selection_type)
    {
    case Selectable:
        if (entity.hasComponent<Hull>()) return true;
        if (entity.getComponent<ScanState>()) return true;
        if (entity.getComponent<ShareShortRangeRadar>()) return true;
        break;
    case Targetable:
        if (entity.hasComponent<Hull>()) return true;
        break;
    case Scannable:
        if (entity.hasComponent<Hull>()) return true;
        if (entity.getComponent<ScanState>()) return true;
        if (entity.getComponent<ScienceDescription>()) return true;
        if (entity.getComponent<ShareShortRangeRadar>()) return true;
        break;
    }
    return false;
}

/*NEXT
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj->entity == my_spaceship)
                    continue;
                if (obj->entity == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (current_found && glm::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && my_spaceship->isEnemy(obj) && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj->entity);
                    PlayerSpaceship::commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj->entity == targets.get())
                {
                    continue;
                }
                if (my_spaceship->isEnemy(obj) && glm::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    PlayerSpaceship::commandSetTarget(targets.get());
                    return;
                }
            }
*/