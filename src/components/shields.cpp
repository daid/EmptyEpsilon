#include "components/shields.h"
#include "vectorUtils.h"


ShipSystem& Shields::getSystemForIndex(int index)
{
    if (count < 2)
        return front_system;
    float angle = index * 360.0f / count;
    if (std::abs(angleDifference(angle, 0.0f)) < 90)
        return front_system;
    return rear_system;
}