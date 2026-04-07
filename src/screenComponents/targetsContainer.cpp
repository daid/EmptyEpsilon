#include "targetsContainer.h"
#include "playerInfo.h"
#include "systems/collision.h"
#include "components/hull.h"
#include "components/collision.h"
#include "components/scanning.h"
#include "components/radar.h"
#include "ecs/query.h"

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
    if (!obj) return;
    for (auto e : entries) if (e == obj) return;
    entries.push_back(obj);
}

void TargetsContainer::set(sp::ecs::Entity obj)
{
    if (obj) entries = {obj};
    else clear();
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
    if (entries.empty()) return {};
    return entries[0];
}

std::vector<sp::ecs::Entity> TargetsContainer::populateEntities(glm::vec2 position, float max_range, ESelectionType selection_type, std::function<bool(sp::ecs::Entity)> filter)
{
    std::vector<sp::ecs::Entity> entities;

    for (auto [entity, transform] : sp::ecs::Query<sp::Transform>())
    {
        if (isValidTarget(entity, selection_type)
            && glm::distance(position, transform.getPosition()) <= max_range
            && filter(entity))
        {
            entities.push_back(entity);
        }
    }

    sortByDistance(position, entities);
    return entities;
}

std::vector<sp::ecs::Entity> TargetsContainer::populateEntities(glm::vec2 position, float max_range, ESelectionType selection_type, KnownFriendOrFoe known_fof)
{
    std::vector<sp::ecs::Entity> entities;

    for (auto [entity, transform] : sp::ecs::Query<sp::Transform>())
    {
        if (isValidTarget(entity, selection_type)
            && glm::distance(position, transform.getPosition()) <= max_range)
        {
            switch (known_fof)
            {
                // Target any entity regardless of FoF state.
                case KnownFriendOrFoe::Any:
                    entities.push_back(entity);
                    break;
                // Target only entities with a known FoF state (skip unknown).
                case KnownFriendOrFoe::Known:
                    if (isFoFKnown(entity)) entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is unknown (skip known).
                case KnownFriendOrFoe::Unknown:
                    if (!isFoFKnown(entity)) entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is known friendly.
                case KnownFriendOrFoe::KnownFriendly:
                    if (isFoFKnown(entity) && Faction::getRelation(my_spaceship, entity) == FactionRelation::Friendly)
                        entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is known non-friendly
                // (neutral, hostile).
                case KnownFriendOrFoe::KnownNonFriendly:
                    if (isFoFKnown(entity) && Faction::getRelation(my_spaceship, entity) != FactionRelation::Friendly)
                        entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is not known friendly
                // (neutral, hostile, unknown).
                case KnownFriendOrFoe::NotKnownFriendly:
                {
                    const bool is_known = isFoFKnown(entity);
                    if (!is_known
                        || (is_known && Faction::getRelation(my_spaceship, entity) != FactionRelation::Friendly))
                    {
                        entities.push_back(entity);
                    }
                    break;
                }
                // Target only entities whose FoF state is known neutral.
                case KnownFriendOrFoe::KnownNeutral:
                    if (isFoFKnown(entity) && Faction::getRelation(my_spaceship, entity) == FactionRelation::Neutral)
                        entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is known non-neutral
                // (friendly, hostile).
                case KnownFriendOrFoe::KnownNonNeutral:
                    if (isFoFKnown(entity) && Faction::getRelation(my_spaceship, entity) != FactionRelation::Neutral)
                        entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is not known neutral
                // (friendly, hostile, unknown).
                case KnownFriendOrFoe::NotKnownNeutral:
                {
                    const bool is_known = isFoFKnown(entity);
                    if (!is_known
                        || (is_known && Faction::getRelation(my_spaceship, entity) != FactionRelation::Neutral))
                    {
                        entities.push_back(entity);
                    }
                    break;
                }
                // Target only entities whose FoF state is known hostile.
                case KnownFriendOrFoe::KnownHostile:
                    if (isFoFKnown(entity) && Faction::getRelation(my_spaceship, entity) == FactionRelation::Enemy)
                        entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is known non-hostile
                // (neutral, friendly).
                case KnownFriendOrFoe::KnownNonHostile:
                    if (isFoFKnown(entity) && Faction::getRelation(my_spaceship, entity) != FactionRelation::Enemy)
                        entities.push_back(entity);
                    break;
                // Target only entities whose FoF state is not known hostile
                // (neutral, friendly, unknown).
                case KnownFriendOrFoe::NotKnownHostile:
                {
                    const bool is_known = isFoFKnown(entity);
                    if (!is_known
                        || (is_known && Faction::getRelation(my_spaceship, entity) != FactionRelation::Enemy))
                    {
                        entities.push_back(entity);
                    }
                    break;
                }
            }
        }
    }

    sortByDistance(position, entities);
    return entities;
}

void TargetsContainer::setToClosestTo(glm::vec2 position, float max_range, ESelectionType selection_type)
{
    sp::ecs::Entity target;
    glm::vec2 target_position;

    for (auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(max_range, max_range), position + glm::vec2(max_range, max_range)))
    {
        if (!isValidTarget(entity, selection_type)) continue;
        auto transform = entity.getComponent<sp::Transform>();
        if (!transform) continue;

        if (!target || glm::length2(position - transform->getPosition()) < glm::length2(position - target_position))
        {
            target = entity;
            target_position = transform->getPosition();
        }
    }

    if (allow_waypoint_selection)
    {
        if (auto waypoints = my_spaceship.getComponent<Waypoints>())
        {
            for (size_t n = 0; n < waypoints->waypoints.size(); n++)
            {
                if (glm::length2(waypoints->waypoints[n].position - position) < max_range * max_range
                    && (!target || glm::length2(position - waypoints->waypoints[n].position) < glm::length2(position - target_position)))
                {
                    clear();
                    waypoint_selection_index = waypoints->waypoints[n].id;
                    return;
                }
            }
        }
    }

    set(target);
}

int TargetsContainer::getWaypointIndex()
{
    auto waypoints = my_spaceship.getComponent<Waypoints>();
    if (!waypoints
        || waypoint_selection_index < 0
        || !waypoints->get(waypoint_selection_index))
    {
        waypoint_selection_index = -1;
    }

    return waypoint_selection_index;
}

void TargetsContainer::setWaypointIndex(int index)
{
    auto waypoints = my_spaceship.getComponent<Waypoints>();
    if (waypoints && waypoints->get(index)) waypoint_selection_index = index;
}

bool TargetsContainer::isFoFKnown(sp::ecs::Entity entity)
{
    auto ss = entity.getComponent<ScanState>();
    if (!ss) return true;
    return ss->getStateFor(my_spaceship) >= ScanState::State::FriendOrFoeIdentified;
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type, KnownFriendOrFoe known_fof)
{
    setNext(position, populateEntities(position, max_range, selection_type, known_fof));
}

void TargetsContainer::setPrev(glm::vec2 position, float max_range, ESelectionType selection_type, KnownFriendOrFoe known_fof)
{
    setPrev(position, populateEntities(position, max_range, selection_type, known_fof));
}

void TargetsContainer::setNext(glm::vec2 position, float max_range, ESelectionType selection_type, std::function<bool(sp::ecs::Entity)> filter)
{
    setNext(position, populateEntities(position, max_range, selection_type, filter));
}

void TargetsContainer::setPrev(glm::vec2 position, float max_range, ESelectionType selection_type, std::function<bool(sp::ecs::Entity)> filter)
{
    setPrev(position, populateEntities(position, max_range, selection_type, filter));
}

void TargetsContainer::setNext(glm::vec2 position, const std::vector<sp::ecs::Entity>& entities)
{
    // Find the first valid entity (closest in the distance-sorted list) for
    // wrap-around.
    sp::ecs::Entity first_valid;
    for (auto entity : entities)
    {
        if (!entity.hasComponent<sp::Transform>()) continue;
        first_valid = entity;
        break;
    }

    if (!first_valid) return;

    bool found_current = false;
    for (auto entity : entities)
    {
        if (!entity.hasComponent<sp::Transform>()) continue;

        // Select the entity after this one, or wrap to the closest if there
        // isn't one.
        if (found_current)
        {
            set(entity);
            my_player_info->commandSetTarget(get());
            return;
        }

        if (get() == entity)
            found_current = true;
    }

    // Current target not in list or at end: select the first/closest entity.
    set(first_valid);
    my_player_info->commandSetTarget(get());
}

void TargetsContainer::setPrev(glm::vec2 position, const std::vector<sp::ecs::Entity>& entities)
{
    // Find the last valid entity (furthest in the distance-sorted list) for
    // wrap-around.
    sp::ecs::Entity last_valid;
    for (auto entity : entities)
    {
        if (!entity.hasComponent<sp::Transform>()) continue;
        last_valid = entity;
    }

    if (!last_valid) return;

    sp::ecs::Entity prev_entity;
    for (auto entity : entities)
    {
        if (!entity.hasComponent<sp::Transform>()) continue;

        // Select the entity before this one, or wrap to the furthest if there
        // isn't one.
        if (get() == entity)
        {
            set(prev_entity ? prev_entity : last_valid);
            my_player_info->commandSetTarget(get());
            return;
        }
        prev_entity = entity;
    }

    // Current target not in list: select the furthest entity.
    set(last_valid);
    my_player_info->commandSetTarget(get());
}

void TargetsContainer::sortByDistance(glm::vec2 position, std::vector<sp::ecs::Entity>& entities)
{
    sort (entities.begin(), entities.end(),
        [position](sp::ecs::Entity a, sp::ecs::Entity b)
        {
            auto transform_a = a.getComponent<sp::Transform>();
            auto transform_b = b.getComponent<sp::Transform>();
            if (!transform_a) return bool(transform_b);
            if (!transform_b) return bool(transform_a);

            return glm::distance(position, transform_a->getPosition()) < glm::distance(position, transform_b->getPosition());
        }
    );
}

bool TargetsContainer::isValidTarget(sp::ecs::Entity entity, ESelectionType selection_type)
{
    if (entity == my_spaceship) return false;

    switch (selection_type)
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
