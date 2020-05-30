#include "tractorBeam.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "spaceObjects/beamEffect.h"
#include "spaceObjects/spaceObject.h"

TractorBeam::TractorBeam() : max_area(0), drag_per_second(0), parent(nullptr), mode(TBM_Off), arc(0), direction(0), range(0) {}

void TractorBeam::setParent(SpaceShip* parent)
{
    assert(!this->parent);
    this->parent = parent;

    parent->registerMemberReplication(&max_area);
    parent->registerMemberReplication(&drag_per_second);
    parent->registerMemberReplication(&arc);
    parent->registerMemberReplication(&direction);
    parent->registerMemberReplication(&range);
}

void TractorBeam::setMode(ETractorBeamMode mode)
{
    this->mode = mode;
}

ETractorBeamMode TractorBeam::getMode()
{
    return mode;
}

void TractorBeam::setMaxArea(float max_area)
{
    this->max_area = max_area;
}

float TractorBeam::getMaxArea()
{
    return max_area;
}

void TractorBeam::setDragPerSecond(float drag_per_second)
{
    this->drag_per_second = drag_per_second;
}

float TractorBeam::getDragPerSecond()
{
    return drag_per_second;
}

float TractorBeam::getMaxRange(float arc)
{
    // M_PI * range * range * arc / 360 <= max_area
    return sqrtf((max_area * 360) / (M_PI * std::max(1.0f, arc)));
}

void TractorBeam::setArc(float arc)
{
    this->arc = arc;
}

float TractorBeam::getArc()
{
    return arc;
}

void TractorBeam::setDirection(float direction)
{
     while(direction < 0)
        direction += 360;
    while(direction > 360)
        direction -= 360;
    this->direction = direction;
}

float TractorBeam::getDirection()
{
    return direction;
}


float TractorBeam::getMaxArc(float range)
{
    // M_PI * range * range * arc / 360 <= max_area
    return (max_area * 360) / (M_PI * std::max(1.0f, range * range));
}
void TractorBeam::setRange(float range)
{
    this->range = range;
}

float TractorBeam::getRange()
{
    return range;
}

float TractorBeam::getDragSpeed()
{
    return getDragPerSecond() * parent->getSystemEffectiveness(SYS_Docks);
}

void TractorBeam::update(float delta)
{
    if (game_server && mode > TBM_Off && range > 0.0 && delta > 0)
    {
        float dragCapability = delta * getDragSpeed();

        foreach(SpaceObject, target, space_object_list)
        {
            if (target != parent) {
                // Get the angle to the target.

                sf::Vector2f diff = target->getPosition() - parent->getPosition();
                float angle_diff = fabsf(sf::angleDifference(direction + parent->getRotation(), sf::vector2ToAngle(diff)));

                // If the target is in the beam's arc and range 
                if (sf::length(diff) < range && angle_diff < arc / 2.0)
                {
                    sf::Vector2f destination;
                    switch(mode) {
                        case TBM_Pull : 
                            destination = parent->getPosition();
                            break;
                        case TBM_Push :
                            destination = parent->getPosition() + normalize(target->getPosition() - parent->getPosition()) * (range * 2);
                            break;
                        case TBM_Hold :
                            destination = parent->getPosition() + normalize(target->getPosition() - parent->getPosition()) * (range / 2);
                            break;
                        case TBM_Off :
                        default:
                            break;
                    }
                    diff = target->getPosition() - destination;
                    float target_distance = std::max(0.0f, sf::length(diff) - parent->getRadius() - target->getRadius());
                    float distanceToDrag = std::min(target_distance, dragCapability);
                    if (parent->useEnergy(energy_per_target_u * distanceToDrag))
                    {
                        P<PlayerSpaceship> target_ship = target;
                        if (target_distance < dragCapability && target_ship && mode == TBM_Pull)
                        {
                            // if tractor beam is dragging a ship into parent, force docking
                            target_ship->requestDock(parent);
                        }
                        distanceToDrag *= (100 / target->getRadius());
                        target->setPosition(target->getPosition() - (distanceToDrag * normalize(diff)));
                    }
                }
            }
        }
    }
}

string getTractorBeamModeName(ETractorBeamMode mode)
{
    switch(mode)
    {
    case TBM_Off:
        return "Off";
    case TBM_Pull:
        return "Pull";
    case TBM_Push:
        return "Push";
    case TBM_Hold:
        return "Hold";
    default:
        return "UNK: " + string(int(mode));
    }
}

#ifndef _MSC_VER
// MFC: GCC does proper external template instantiation, VC++ doesn't.
#include "tractorBeam.hpp"
#endif
