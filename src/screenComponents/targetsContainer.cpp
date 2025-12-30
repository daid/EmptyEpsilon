#include "targetsContainer.h"
#include "playerInfo.h"
#include "ecs/query.h"

#include "systems/collision.h"
#include "components/collision.h"
#include "components/comms.h"
#include "components/health.h"
#include "components/hull.h"
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
        if (auto waypoints = my_spaceship.getComponent<Waypoints>()) {
            for(size_t n=0; n<waypoints->waypoints.size(); n++)
            {
                if (glm::length2(waypoints->waypoints[n].position - position) < max_range*max_range)
                {
                    if (!target || glm::length2(position - waypoints->waypoints[n].position) < glm::length2(position - target_position))
                    {
                        clear();
                        waypoint_selection_index = waypoints->waypoints[n].id;
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
    auto waypoints = my_spaceship.getComponent<Waypoints>();
    if (!waypoints || waypoint_selection_index < 0 || !waypoints->get(waypoint_selection_index))
        waypoint_selection_index = -1;
    return waypoint_selection_index;
}

void TargetsContainer::setWaypointIndex(int index)
{
    auto waypoints = my_spaceship.getComponent<Waypoints>();
    if (waypoints && waypoints->get(index))
        waypoint_selection_index = index;
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type)
{
    std::vector<sp::ecs::Entity> entities;

    for(auto [entity, transform] : sp::ecs::Query<sp::Transform>()) {
        if(isValidTarget(entity, selection_type) && glm::distance(position, transform.getPosition()) <= max_range) {
            entities.push_back(entity);
        }
    }

    sortByDistance(position, entities);
    setNext(position, max_range, entities);
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type, FactionRelation relation)
{
    std::vector<sp::ecs::Entity> entities;
    for(auto [entity, transform] : sp::ecs::Query<sp::Transform>()) {
        if(isValidTarget(entity, selection_type) && glm::distance(position, transform.getPosition()) <= max_range && Faction::getRelation(my_spaceship, entity) == relation) {
            entities.push_back(entity);
        }
    }

    sortByDistance(position, entities);
    setNext(position, max_range, entities);
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, std::vector<sp::ecs::Entity> &entities)
{
    sp::ecs::Entity default_target;
    sp::ecs::Entity current_target;
    glm::vec2 default_target_position;

    for (auto entity : entities) {
        auto transform = entity.getComponent<sp::Transform>();

        if (!transform)
            continue;

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
            my_player_info->commandSetTarget(get());
            return;
        }

        if (get() == entity) {
            current_target = entity;
        }
    }

    // If we didn't short-circuit because of an existing target above, set the
    // target to be the default_target (closest to `position`)
    set(default_target);
    my_player_info->commandSetTarget(get());
}

void TargetsContainer::sortByDistance(glm::vec2 position, std::vector<sp::ecs::Entity>& entities)
{
    sort(entities.begin(), entities.end(), [position](sp::ecs::Entity a, sp::ecs::Entity b) {
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

    const bool has_health = entity.hasComponent<Health>();
    const bool has_hull = entity.hasComponent<Hull>();

    switch (selection_type)
    {
    case Selectable: // Used by Relay
        // Always select entities with both Health and Hull.
        if (has_health && has_hull) return true;
        // Always select entities if they share radar.
        if (entity.getComponent<ShareShortRangeRadar>()) return true;

        // Select entities if they're CommsReceivers.
        if (has_health && !has_hull)
            if (entity.hasComponent<CommsReceiver>()) return true;
        break;

    case Hackable: // Used by Relay
        // Can hack entities with a hackable ShipSystem.
        for (int n = 0; n < static_cast<int>(ShipSystem::Type::COUNT); n++)
        {
            auto sys = ShipSystem::get(entity, ShipSystem::Type(n));
            if (sys && sys->can_be_hacked) return true;
        };
        break;

    case Targetable: // Used by Weapons
        // Weapons target anything with Health.
        if (has_health) return true;
        break;

    case Scannable: // Used by Science
        // Can scan entities that have both Health and Hull.
        if (has_health && has_hull) return true;

        // Can scan entities without Health if they have scan state or
        // description, or share radar.
        if (entity.hasComponent<ScanState>()) return true;
        if (entity.hasComponent<ScienceDescription>()) return true;
        if (entity.hasComponent<ShareShortRangeRadar>()) return true;
        break;
    }

    return false;
}
