#include "tractorBeamTemplate.h"

TractorBeamTemplate::TractorBeamTemplate(): max_area(0), drag_per_second(0) {}

float TractorBeamTemplate::getMaxArea()
{
    return max_area;
}

void TractorBeamTemplate::setMaxArea(float max_area)
{
    this->max_area = max_area;
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
