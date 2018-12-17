#ifndef SHIP_FILTER_H
#define SHIP_FILTER_H

#include "playerInfo.h"


class ShipFilter 
{
    std::map<string, string> ship_filters;
    ECrewPosition crew_position;
public:
    ShipFilter(string ship_filter = "", ECrewPosition crew_position = max_crew_positions);
    P<PlayerSpaceship>  findValidShip() const;
    void log() const;
private:
    bool isValidShip(P<PlayerSpaceship> index) const;
};

#endif//SHIP_FILTER_H
