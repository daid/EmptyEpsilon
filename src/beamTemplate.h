#ifndef BEAM_TEMPLATE_H
#define BEAM_TEMPLATE_H

#include "SFML/System/NonCopyable.hpp"

#include "stringImproved.h"

class BeamTemplate : public sf::NonCopyable
{
public:
    BeamTemplate();
    float arc;
    float direction;
    float range;
    float cycle_time;
    float damage;
    string beam_texture;
};

#endif //BEAM_TEMPLATE_H