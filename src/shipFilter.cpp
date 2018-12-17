#include "shipFilter.h"
#include "gameGlobalInfo.h"

ShipFilter::ShipFilter(string ship_filter, ECrewPosition crew_position) : crew_position(crew_position)
{
    for (string filter : ship_filter.split(";"))
    {
        std::vector<string> key_value = filter.split("=", 1);
        string key = key_value[0].strip().lower();
        if (key.length() < 1)
            continue;

        if (key_value.size() == 1)
            ship_filters[key] = "1";
        else if (key_value.size() == 2)
            ship_filters[key] = key_value[1].strip();
    }
}

void ShipFilter::log()
{
    for (auto& entry : ship_filters) 
    {
        LOG(INFO) << "Auto connect filter: " << entry.first << " = " << entry.second;
    }
}

P<PlayerSpaceship> ShipFilter::findValidShip()
{
    for (int n = 0; n < GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (isValidShip(ship))
        {
            return ship;
        }
    }
    return nullptr;
}

bool ShipFilter::isValidShip(P<PlayerSpaceship> ship)
{
    if (!ship || !ship->ship_template)
        return false;

    for (auto it : ship_filters)
    {
        if (it.first == "solo")
        {
            int crew_at_position = 0;
            foreach (PlayerInfo, i, player_info_list)
            {
                if (i->ship_id == ship->getMultiplayerId())
                {
                    if (crew_position != max_crew_positions && i->crew_position[crew_position])
                        crew_at_position++;
                }
            }
            if (crew_at_position > 0)
                return false;
        }
        else if (it.first == "faction")
        {
            if (ship->getFactionId() != FactionInfo::findFactionId(it.second))
                return false;
        }
        else if (it.first == "callsign")
        {
            if (ship->getCallSign().lower() != it.second.lower())
                return false;
        }
        else if (it.first == "type")
        {
            if (ship->getTypeName().lower() != it.second.lower())
                return false;
        }
        else
        {
            LOG(WARNING) << "Unknown ship filter: " << it.first << " = " << it.second;
        }
    }
    return true;
}
