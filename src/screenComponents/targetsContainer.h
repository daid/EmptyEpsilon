#ifndef TARGETS_CONTAINER_H
#define TARGETS_CONTAINER_H

#include "spaceObjects/spaceObject.h"

class TargetsContainer
{
private:
    PVector<SpaceObject> entries;
public:

    void clear() { entries.clear(); }
    void add(P<SpaceObject> obj) { if (obj) entries.push_back(obj); }
    void set(P<SpaceObject> obj);
    void set(PVector<SpaceObject> objs);
    PVector<SpaceObject> getTargets() { entries.update(); return entries; }
    P<SpaceObject> get() { entries.update(); if (entries.size() > 0) return entries[0]; return nullptr; }
    
    void setToClosestTo(sf::Vector2f position, float max_range);
};

#endif//TARGETS_CONTAINER_H
