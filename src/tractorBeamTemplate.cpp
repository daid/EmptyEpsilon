#include "tractorBeamTemplate.h"
#include <math.h>

TractorBeamTemplate::TractorBeamTemplate(): max_area(0), drag_per_second(0) {}

float TractorBeamTemplate::getMaxArea()
{
    return max_area;
}

void TractorBeamTemplate::setMaxArea(float max_area)
{
    this->max_area = max_area;
}

void TractorBeamTemplate::setMaxRange(float max_range)
{
    this->max_area = (max_range * max_range * M_PI * 6.0) / 360;
}

float TractorBeamTemplate::getDragPerSecond()
{
    return drag_per_second;
}

void TractorBeamTemplate::setDragPerSecond(float drag_per_second)
{
    this->drag_per_second = drag_per_second;
}

TractorBeamTemplate& TractorBeamTemplate::operator=(const TractorBeamTemplate& other)
{
    max_area = other.max_area;
    drag_per_second = other.drag_per_second;
    return *this;
}
