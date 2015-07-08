#ifndef TARGETS_CONTAINER_H
#define TARGETS_CONTAINER_H

#include "spaceObjects/spaceObject.h"

class TargetsContainer
{
public:
    PVector<SpaceObject> entries;

    void clear() { entries.clear(); }
    void add(P<SpaceObject> obj) { if (obj) entries.push_back(obj); }
    void set(P<SpaceObject> obj);
    void set(PVector<SpaceObject> objs);
    PVector<SpaceObject> getTargets() { return entries; }
};

#endif//TARGETS_CONTAINER_H
