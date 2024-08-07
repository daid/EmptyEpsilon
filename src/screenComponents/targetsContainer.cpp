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

    auto entities = sp::CollisionSystem::queryArea(position - glm::vec2(max_range, max_range), position + glm::vec2(max_range, max_range));
    std::vector<sp::ecs::Entity> relevant_entities;
    std::copy_if (entities.begin(), entities.end(), std::back_inserter(relevant_entities), [this, selection_type](sp::ecs::Entity entity){
        return isValidTarget(entity, selection_type);
    });

    sortByDistance(position, &entities);
    setNext(position, max_range, &relevant_entities);

    // PlayerSpaceship::commandSetTarget(targets.get());
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type, FactionRelation relation)
{
    auto entities = sp::CollisionSystem::queryArea(position - glm::vec2(max_range, max_range), position + glm::vec2(max_range, max_range));
    std::vector<sp::ecs::Entity> relevant_entities;
    std::copy_if (entities.begin(), entities.end(), std::back_inserter(relevant_entities), [this, selection_type, relation](sp::ecs::Entity entity){
        return isValidTarget(entity, selection_type) && Faction::getRelation(my_spaceship, entity) == relation;
    });

    sortByDistance(position, &relevant_entities);
    setNext(position, max_range, &relevant_entities);

    // PlayerSpaceship::commandSetTarget(targets.get());
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, std::vector<sp::ecs::Entity> *entities)
{
    sp::ecs::Entity default_target;
    sp::ecs::Entity current_target;
    glm::vec2 default_target_position;

    for (auto entity : *entities) {
        auto transform = entity.getComponent<sp::Transform>();

        if (!transform)
            continue;

        // Because we use querArea, we're getting a square back.  It's possible some relevant entities
        // are in corners that shouldn't be targetable on a circular viewport
        if(glm::distance(position, transform->getPosition()) > max_range) {
            continue;
        }

        // Start collecting nearest relevant entities in case we never run into a previous target
        if (!default_target ||
                glm::length2(position - transform->getPosition()) <
                glm::length2(position - default_target_position)) {
            default_target = entity;
            default_target_position = transform->getPosition();
        }

        // if we set a current target in the last iteration (condition below)
        // the set the entity to be this next entity in the list.
        if (current_target) {
            set(entity);
            return;
        }

        if (get() == entity) {
            current_target = entity;
        }
    }

    // If we didn't short-circuit because of an existing target above, set the
    // target to be the default_target (closest to `position`)
    set(default_target);
}

void sortByDistance(glm::vec2 position, std::vector<sp::ecs::Entity> *entities)
{
    sort(entities->begin(), entities->end(), [position](sp::ecs::Entity a, sp::ecs::Entity b) {
        auto transform_a = a.getComponent<sp::Transform>();
        auto transform_b = b.getComponent<sp::Transform>();
        if (!transform_a)
            return bool(transform_b);

        if (!transform_b)
            return bool(transform_a);

        return glm::distance(position, transform_a->getPosition()) < glm::distance(position, transform_b->getPosition());
    });

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