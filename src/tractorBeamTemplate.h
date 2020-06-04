#ifndef TRACTOR_BEAM_TEMPLATE_H
#define TRACTOR_BEAM_TEMPLATE_H

#include "SFML/System/NonCopyable.hpp"

#include "stringImproved.h"

class TractorBeamTemplate : public sf::NonCopyable
{
public:
    TractorBeamTemplate();

    float getMaxArea();
    void setMaxArea(float max_area);
    void setMaxRange(float max_range);

    void setDragPerSecond(float drag_per_second);
    float getDragPerSecond();
    
    TractorBeamTemplate& operator=(const TractorBeamTemplate& other);

protected:
    float max_area; // Value greater than or equal to 0
    float drag_per_second; // Value greater than 0
};

#endif//TRACTOR_BEAM_TEMPLATE_H
