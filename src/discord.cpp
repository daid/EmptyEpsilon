#include "discord.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include <discord_game_sdk.h>

static IDiscordCore* core;
static IDiscordActivityManager* activityManager;
static IDiscordCoreEvents events;

static DiscordActivity previousActivity;

DiscordRichPresence::DiscordRichPresence()
{
    DiscordCreateParams params;
    params.client_id = 697525001603252304;
    params.flags = DiscordCreateFlags_NoRequireDiscord;
    params.events = &events;
    params.event_data = nullptr;

    if (DiscordCreate(DISCORD_VERSION, &params, &core) != DiscordResult_Ok)
    {
        LOG(WARNING) << "Discord not installed or not running. Not using discord rich presence";
        return;
    }

    activityManager = core->get_activity_manager(core);
}

void DiscordRichPresence::update(float delta)
{
    if (!core)
        return;

    core->run_callbacks(core);

    if (updateDelay >= 0.0f)
        updateDelay -= delta;
    if (updateDelay >= 0.0f)
        return;

    DiscordActivity activity;
    memset(&activity, 0, sizeof(activity));
    strcpy(activity.assets.large_image, "logo");

    if (my_spaceship && my_player_info)
    {
        auto name = my_spaceship->getCallSign() + " [" + my_spaceship->getTypeName() + "]";
        strncpy(activity.details, name.c_str(), sizeof(activity.details));

        for(int idx=0; idx<max_crew_positions; idx++)
        {
            if (my_player_info->crew_position[idx])
            {
                strncpy(activity.state, getCrewPositionName(ECrewPosition(idx)).c_str(), sizeof(activity.state));
                if (idx == helmsOfficer)
                    strcpy(activity.assets.small_image, "helms_white");
                if (idx == weaponsOfficer)
                    strcpy(activity.assets.small_image, "weapons_white");
                if (idx == engineering)
                    strcpy(activity.assets.small_image, "engineering_white");
                if (idx == scienceOfficer)
                    strcpy(activity.assets.small_image, "science_white");
                if (idx == relayOfficer)
                    strcpy(activity.assets.small_image, "relay_white");
                break;
            }
        }
        if (my_player_info->isOnlyMainScreen())
        {
            strncpy(activity.state, "Captain", sizeof(activity.state));
            strcpy(activity.assets.small_image, "captain_white");
        }
    }

    if (memcmp(&activity, &previousActivity, sizeof(activity)) != 0)
    {
        activityManager->update_activity(activityManager, &activity, nullptr, nullptr);
        previousActivity = activity;
        updateDelay = 4.0;
    }
}
