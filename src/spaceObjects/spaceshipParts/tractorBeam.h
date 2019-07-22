#ifndef TRACTOR_BEAM_H
#define TRACTOR_BEAM_H

#include "SFML/System/NonCopyable.hpp"
#include "stringImproved.h"
#include "spaceObjects/spaceObject.h"
class SpaceShip;

enum ETractorBeamMode
{
    TBM_Off,        // Tractor beam off
    TBM_Pull,       // pull objects to ship
    TBM_Push,       // push objects away from ship
    TBM_Hold        // hold objects near ship
};
/* Define script conversion function for the EMissileWeapons enum. */
template<> void convert<ETractorBeamMode>::param(lua_State* L, int& idx, ETractorBeamMode& es);
template<> int convert<ETractorBeamMode>::returnType(lua_State* L, ETractorBeamMode es);

class TractorBeam : public sf::NonCopyable
{
protected:
    //Beam configuration
    float max_area; // Value greater than or equal to 0
    float drag_per_second; // Value greater than 0
    SpaceShip* parent; //The ship that this beam weapon is attached to.

    // Beam state
    ETractorBeamMode mode;
    float arc; 
    float direction;
    float range;
public:
    constexpr static float energy_per_target_u = 0.05f; /*< Amount of energy it takes to drag a target (of radius 100) for 1U */

    TractorBeam();

    void setParent(SpaceShip* parent);

    ETractorBeamMode getMode();
    void setMode(ETractorBeamMode mode);

    float getMaxArea();
    void setMaxArea(float max_area);

    void setDragPerSecond(float drag_per_second);
    float getDragPerSecond();
    
    void setArc(float arc);
    float getArc();

    void setDirection(float direction);
    float getDirection();

    void setRange(float range);
    float getRange();
        
    float getDragSpeed();
    float getMaxArc(float range);
    float getMaxRange(float arc);
    void update(float delta);
};
string getTractorBeamModeName(ETractorBeamMode mode);

#ifdef _MSC_VER
// MFC: GCC does proper external template instantiation, VC++ doesn't.
#include "tractorBeam.hpp"
#endif

#endif//TRACTOR_BEAM_H
