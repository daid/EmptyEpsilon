#include "playerInfo.h"
#include "targetsContainer.h"

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
}

void TargetsContainer::set(PVector<SpaceObject> objs)
{
    entries = objs;
}

void TargetsContainer::setToClosestTo(sf::Vector2f position, float max_range)
{
    P<SpaceObject> target;
    PVector<Collisionable> list = CollisionManager::queryArea(position - sf::Vector2f(max_range, max_range), position + sf::Vector2f(max_range, max_range));
    foreach(Collisionable, obj, list)
    {
        P<SpaceObject> spaceObject = obj;
        if (spaceObject && spaceObject->canBeTargeted() && spaceObject != my_spaceship)
        {
            if (!target || sf::length(position - spaceObject->getPosition()) < sf::length(position - target->getPosition()))
                target = spaceObject;
        }
    }
    set(target);
}
