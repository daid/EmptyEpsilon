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

    main_screen_radar = new GuiRadarView(viewport, "VIEWPORT_RADAR", 5000.0f, nullptr);
    main_screen_radar->setStyle(GuiRadarView::CircularMasked)->setSize(200, 200)->setPosition(-20, 20, sp::Alignment::TopRight);

    tactical_radar = new GuiRadarView(this, "TACTICAL", 10000.0f, nullptr);
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

    keyboard_help = new GuiHelpOverlay(this, tr("hotkey_F1", "Keyboard Shortcuts"));

    for (auto binding : sp::io::Keybinding::listAllByCategory(tr("hotkey_menu", "Main Screen")))
        keyboard_general += tr("hotkey_F1", "{label}:\t{button}\n").format({{"label", binding->getLabel()}, {"button", binding->getHumanReadableKeyName(0)}});

    keyboard_help->setText(keyboard_general);

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
    if (keys.help.getDown())
    {
        // Toggle keyboard help.
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());
    }
    if (keys.pause.getDown())
    {
        if (game_server)
            engine->setGameSpeed(0.0);
    }

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
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Front:
        case MSS_Back:
        case MSS_Left:
        case MSS_Right:
        case MSS_Target:
            viewport->show();
            tactical_radar->hide();
            long_range_radar->hide();
            break;
        case MSS_Tactical:
            viewport->hide();
            tactical_radar->show();
            long_range_radar->hide();
            break;
        case MSS_LongRange:
            viewport->hide();
            tactical_radar->hide();
            long_range_radar->show();
            break;
        }

        switch(my_spaceship->main_screen_overlay)
        {
        case MSO_ShowComms:
            onscreen_comms->clearElements();
            onscreen_comms->show();
            break;
        case MSO_HideComms:
            onscreen_comms->clearElements();
            onscreen_comms->hide();
            break;
        }

        // Update impulse sound volume and pitch.
        impulse_sound->update(delta);
    } else {
        // If we're not the player ship (ie. we exploded), don't play impulse
        // engine sounds.
        impulse_sound->stop();
    }

    if (my_spaceship)
    {
        if (keys.mainscreen_forward.getDown())
            my_spaceship->commandMainScreenSetting(MSS_Front);
        if (keys.mainscreen_left.getDown())
            my_spaceship->commandMainScreenSetting(MSS_Left);
        if (keys.mainscreen_right.getDown())
            my_spaceship->commandMainScreenSetting(MSS_Right);
        if (keys.mainscreen_back.getDown())
            my_spaceship->commandMainScreenSetting(MSS_Back);
        if (keys.mainscreen_target.getDown())
            my_spaceship->commandMainScreenSetting(MSS_Target);
        if (keys.mainscreen_tactical_radar.getDown())
            my_spaceship->commandMainScreenSetting(MSS_Tactical);
        if (keys.mainscreen_long_range_radar.getDown())
            my_spaceship->commandMainScreenSetting(MSS_LongRange);
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

        switch (my_spaceship->main_screen_setting)
        {
        case MSS_Tactical:
            button = check_radar(*tactical_radar);
            break;
        case MSS_LongRange:
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
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Front: my_spaceship->commandMainScreenSetting(MSS_Left); break;
        case MSS_Left: my_spaceship->commandMainScreenSetting(MSS_Back); break;
        case MSS_Back: my_spaceship->commandMainScreenSetting(MSS_Right); break;
        case MSS_Right: my_spaceship->commandMainScreenSetting(MSS_Front); break;
        default: my_spaceship->commandMainScreenSetting(MSS_Front); break;
        }
        break;
    case sp::io::Pointer::Button::Right:
        switch(my_spaceship->main_screen_setting)
        {
        case MSS_Front: my_spaceship->commandMainScreenSetting(MSS_Right); break;
        case MSS_Right: my_spaceship->commandMainScreenSetting(MSS_Back); break;
        case MSS_Back: my_spaceship->commandMainScreenSetting(MSS_Left); break;
        case MSS_Left: my_spaceship->commandMainScreenSetting(MSS_Front); break;
        default: my_spaceship->commandMainScreenSetting(MSS_Front); break;
        }
        break;
    case sp::io::Pointer::Button::Middle:
        switch(my_spaceship->main_screen_setting)
        {
        default:
            if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_spaceship->commandMainScreenSetting(MSS_Tactical);
            else if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_LongRange);
            break;
        case MSS_Tactical:
            if (gameGlobalInfo->allow_main_screen_long_range_radar)
                my_spaceship->commandMainScreenSetting(MSS_LongRange);
            break;
        case MSS_LongRange:
            if (gameGlobalInfo->allow_main_screen_tactical_radar)
                my_spaceship->commandMainScreenSetting(MSS_Tactical);
            break;
        }
        break;
    default:
        break;
    }
    return true;
}
