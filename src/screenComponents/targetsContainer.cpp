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
