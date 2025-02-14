#include "steamrichpresence.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "components/name.h"
#include <steam/steam_api.h>


SteamRichPresence::SteamRichPresence()
{
}

SteamRichPresence::~SteamRichPresence() = default;

void SteamRichPresence::update(float delta)
{
    if (updateDelay >= 0.0f)
        updateDelay -= delta;
    if (updateDelay >= 0.0f)
        return;

    string status = "";
    if (my_spaceship && my_player_info)
    {
        auto cs = my_spaceship.getComponent<CallSign>();
        if (cs)
            status = cs->callsign;
        auto tn = my_spaceship.getComponent<TypeName>();
        if (tn)
            status += " [" + tn->type_name + "]";

        for(int idx=0; idx<int(CrewPosition::MAX); idx++)
        {
            auto cp = CrewPosition(idx);
            if (my_player_info->hasPosition(cp))
            {
                status += " " + getCrewPositionName(cp);
                break;
            }
        }
        if (my_player_info->isOnlyMainScreen(0))
        {
            status += " Captain";
        }
    }

    SteamFriends()->SetRichPresence("status", status.c_str());
}
