#include "discord.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/playerSpaceship.h"
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
        status = my_spaceship->getCallSign() + " [" + my_spaceship->getTypeName() + "]";

        for(int idx=0; idx<max_crew_positions; idx++)
        {
            if (my_player_info->crew_position[idx])
            {
                status += " " + getCrewPositionName(ECrewPosition(idx));
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
