#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "mainScreen.h"
#include "main.h"
#include "epsilonServer.h"
#include "preferenceManager.h"
#include "soundManager.h"
#include "multiplayer_client.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/selfDestructIndicator.h"
#include "screenComponents/globalMessage.h"
#include "screenComponents/jumpIndicator.h"
#include "screenComponents/commsOverlay.h"
#include "screenComponents/viewportMainScreen.h"
#include "screenComponents/radarView.h"
#include "screenComponents/shipDestroyedPopup.h"
#include "screenComponents/impulseSound.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_overlay.h"

#include <i18n.h>

ScreenMainScreen::ScreenMainScreen(RenderLayer* render_layer)
: GuiCanvas(render_layer)
{
    new GuiOverlay(this, "", glm::u8vec4(0,0,0,255));

    viewport = new GuiViewportMainScreen(this, "VIEWPORT");
    viewport->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    main_screen_radar = new GuiRadarView(viewport, "VIEWPORT_RADAR", nullptr);
    main_screen_radar->setStyle(GuiRadarView::CircularMasked)->setSize(200, 200)->setPosition(-20, 20, sp::Alignment::TopRight);

    tactical_radar = new GuiRadarView(this, "TACTICAL", nullptr);
    tactical_radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    tactical_radar->setRangeIndicatorStepSize(1000.0f)->shortRange()->enableCallsigns()->hide();
    long_range_radar = new GuiRadarView(this, "TACTICAL", nullptr);
    long_range_radar->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    long_range_radar->setRangeIndicatorStepSize(5000.0f)->longRange()->enableCallsigns()->hide();
    long_range_radar->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);
    onscreen_comms = new GuiCommsOverlay(this);
    onscreen_comms->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setVisible(false);

    new GuiShipDestroyedPopup(this);

    new GuiJumpIndicator(this);
    new GuiSelfDestructIndicator(this);
    new GuiGlobalMessage(this);
    (new GuiIndicatorOverlays(this))->hasGlobalMessage();

    std::vector<string> hotkey_categories = {tr("hotkey_menu", "Console"), tr("hotkey_menu", "Basic"), tr("hotkey_menu", "Main Screen")};
    if (PreferencesManager::get("voice_chat_enabled", "1") == "1")
        hotkey_categories.emplace_back(tr("hotkey_menu", "Voice Chat"));
    keyboard_help = new GuiHotkeyHelpOverlay(this, hotkey_categories);

    if (PreferencesManager::get("music_enabled") != "0")
    {
        threat_estimate = new ThreatLevelEstimate();
        threat_estimate->setCallbacks([](){
            LOG(INFO) << "Switching to ambient music";
            soundManager->playMusicSet(findResources("music/ambient/*.ogg"));
        }, []() {
            LOG(INFO) << "Switching to combat music";
            soundManager->playMusicSet(findResources("music/combat/*.ogg"));
        });
    }

    // Initialize and play the impulse engine sound.
    impulse_sound = std::unique_ptr<ImpulseSound>( new ImpulseSound(PreferencesManager::get("impulse_sound_enabled", "2") != "0") );
}

void ScreenMainScreen::destroy()
{
    if (threat_estimate)
        threat_estimate->destroy();
    PObject::destroy();
}

void ScreenMainScreen::update(float delta)
{
    if (keys.escape.getDown())
    {
        soundManager->stopMusic();
        impulse_sound->stop();
        destroy();
        returnToShipSelection(getRenderLayer());
    }

    // Toggle keyboard help.
    if (keys.help.getDown()) keyboard_help->toggle();

    if (keys.pause.getDown())
        if (game_server && !gameGlobalInfo->getVictoryFaction()) engine->setGameSpeed(engine->getGameSpeed() > 0.0f ? 0.0f : 1.0f);

    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        soundManager->stopMusic();
        impulse_sound->stop();
        destroy();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
        return;
    }

    if (my_spaceship)
    {
        if (auto pc = my_spaceship.getComponent<PlayerControl>()) {
            switch(pc->main_screen_setting)
            {
            case MainScreenSetting::Front:
            case MainScreenSetting::Back:
            case MainScreenSetting::Left:
            case MainScreenSetting::Right:
            case MainScreenSetting::Target:
                viewport->show();
                tactical_radar->hide();
                long_range_radar->hide();
                break;
            case MainScreenSetting::Tactical:
                viewport->hide();
                tactical_radar->show();
                long_range_radar->hide();
                break;
            case MainScreenSetting::LongRange:
                viewport->hide();
                tactical_radar->hide();
                long_range_radar->show();
                break;
            }

            switch(pc->main_screen_overlay)
            {
            case MainScreenOverlay::ShowComms:
                onscreen_comms->clearElements();
                onscreen_comms->show();
                break;
            case MainScreenOverlay::HideComms:
                onscreen_comms->clearElements();
                onscreen_comms->hide();
                break;
            }
        }

        // Update impulse sound volume and pitch.
        impulse_sound->update(delta);
    }
    else
    {
        // If we're not the player ship (ie. we exploded), don't play impulse
        // engine sounds.
        impulse_sound->stop();
    }

    if (my_spaceship)
    {
        if (keys.mainscreen_forward.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::Front);
        if (keys.mainscreen_left.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::Left);
        if (keys.mainscreen_right.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::Right);
        if (keys.mainscreen_back.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::Back);
        if (keys.mainscreen_target.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::Target);
        if (keys.mainscreen_tactical_radar.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::Tactical);
        if (keys.mainscreen_long_range_radar.getDown())
            my_player_info->commandMainScreenSetting(MainScreenSetting::LongRange);
        if (keys.mainscreen_first_person.getDown())
            viewport->first_person = !viewport->first_person;
    }
}

bool ScreenMainScreen::onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (GuiCanvas::onPointerDown(button, position, id))
        return true;
    if (!my_spaceship)
        return false;

    auto pc = my_spaceship.getComponent<PlayerControl>();
    if (!pc)
        return false;

    if (button == sp::io::Pointer::Button::Touch && id != sp::io::Pointer::mouse)
    {
        // When the radar is up, clicking 'inside' toggles (middle mouse),
        // 'outside' closes (Left mouse).
        auto check_radar = [position](const auto& radar)
        {
            auto size = radar.getRect().size;
            auto radius = std::min(size.x, size.y) / 2.f;
            if (glm::length(position - radar.getCenterPoint()) < radius)
                return sp::io::Pointer::Button::Middle;

            return sp::io::Pointer::Button::Left;
        };

        switch (pc->main_screen_setting)
        {
        case MainScreenSetting::Tactical:
            button = check_radar(*tactical_radar);
            break;
        case MainScreenSetting::LongRange:
            button = check_radar(*long_range_radar);
            break;
        default:
            // Tapping the radar brings it up (middle mouse)
            if (main_screen_radar->getRect().contains(position))
                button = sp::io::Pointer::Button::Middle;
            else
            {
                // Split screen in two - tapping left rotates left (as if left mouse), and right... right.
                if (position.x < viewport->getCenterPoint().x)
                    button = sp::io::Pointer::Button::Left;
                else
                    button = sp::io::Pointer::Button::Right;
            }
        }
    }

    switch(button)
    {
    case sp::io::Pointer::Button::Left:
        [[fallthrough]];
    case sp::io::Pointer::Button::Touch:
        switch(pc->main_screen_setting)
        {
        case MainScreenSetting::Front: my_player_info->commandMainScreenSetting(MainScreenSetting::Left); break;
        case MainScreenSetting::Left: my_player_info->commandMainScreenSetting(MainScreenSetting::Back); break;
        case MainScreenSetting::Back: my_player_info->commandMainScreenSetting(MainScreenSetting::Right); break;
        case MainScreenSetting::Right: my_player_info->commandMainScreenSetting(MainScreenSetting::Front); break;
        default: my_player_info->commandMainScreenSetting(MainScreenSetting::Front); break;
        }
        break;
    case sp::io::Pointer::Button::Right:
        switch(pc->main_screen_setting)
        {
        case MainScreenSetting::Front: my_player_info->commandMainScreenSetting(MainScreenSetting::Right); break;
        case MainScreenSetting::Right: my_player_info->commandMainScreenSetting(MainScreenSetting::Back); break;
        case MainScreenSetting::Back: my_player_info->commandMainScreenSetting(MainScreenSetting::Left); break;
        case MainScreenSetting::Left: my_player_info->commandMainScreenSetting(MainScreenSetting::Front); break;
        default: my_player_info->commandMainScreenSetting(MainScreenSetting::Front); break;
        }
        break;
    case sp::io::Pointer::Button::Middle:
        switch(pc->main_screen_setting)
        {
        default:
            if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_player_info->commandMainScreenSetting(MainScreenSetting::Tactical);
            else if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_player_info->commandMainScreenSetting(MainScreenSetting::LongRange);
            break;
        case MainScreenSetting::Tactical:
            if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_player_info->commandMainScreenSetting(MainScreenSetting::LongRange);
            break;
        case MainScreenSetting::LongRange:
            if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_player_info->commandMainScreenSetting(MainScreenSetting::Tactical);
            break;
        }
        break;
    default:
        break;
    }
    return true;
}
