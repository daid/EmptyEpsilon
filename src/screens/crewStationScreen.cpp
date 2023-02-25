#include "crewStationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "preferenceManager.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "multiplayer_client.h"
#include "soundManager.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/noiseOverlay.h"
#include "screenComponents/shipDestroyedPopup.h"
#include "screenComponents/helpOverlay.h"
#include "screenComponents/impulseSound.h"
#include "screenComponents/viewportMainScreen.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "gui/joystickConfig.h"

#include <i18n.h>

CrewStationScreen::CrewStationScreen(RenderLayer* render_layer, bool with_main_screen)
: GuiCanvas(render_layer)
{
    if (with_main_screen)
    {
        // Create a 3D viewport behind everything, to serve as the right-side panel
        viewport = new GuiViewportMainScreen(this, "3D_VIEW");
        viewport->showCallsigns()->showHeadings()->showSpacedust();
        viewport->setPosition(1200, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        viewport->hide();
    }

    main_panel = new GuiElement(this, "MAIN");
    main_panel->setSize(1200, GuiElement::GuiSizeMax);

    select_station_button = new GuiButton(main_panel, "", "", [this]()
    {
        button_strip->show();
    });
    select_station_button->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(250, 50);

    button_strip = new GuiPanel(main_panel, "");
    button_strip->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(250, 50);
    button_strip->hide();

    message_frame = new GuiPanel(main_panel, "");
    message_frame->setPosition(0, 0, sp::Alignment::TopCenter)->setSize(900, 230)->hide();

    message_text = new GuiScrollText(message_frame, "", "");
    message_text->setTextSize(20)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(900 - 40, 200 - 40);
    message_close_button = new GuiButton(message_frame, "", tr("button", "Close"), [this]() {
        if (my_spaceship)
        {
            for(PlayerSpaceship::CustomShipFunction& csf : my_spaceship->custom_functions)
            {
                if (csf.crew_position == current_position && csf.type == PlayerSpaceship::CustomShipFunction::Type::Message)
                {
                    my_spaceship->commandCustomFunction(csf.name);
                    break;
                }
            }
        }
    });
    message_close_button->setTextSize(30)->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(300, 30);

    keyboard_help = new GuiHelpOverlay(main_panel, tr("hotkey_F1", "Keyboard Shortcuts"));

    for (auto binding : sp::io::Keybinding::listAllByCategory("General"))
        keyboard_general += tr("hotkey_F1", "{label}:\t{button}\n").format({{"label", binding->getLabel()}, {"button", binding->getHumanReadableKeyName(0)}});

#ifndef __ANDROID__
    if (PreferencesManager::get("music_enabled") == "1")
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
#endif

    // Initialize and play the impulse engine sound.
    impulse_sound = std::unique_ptr<ImpulseSound>( new ImpulseSound(PreferencesManager::get("impulse_sound_enabled", "2") == "1") );
}

void CrewStationScreen::destroy()
{
    if (threat_estimate)
        threat_estimate->destroy();
    PObject::destroy();
}

GuiContainer* CrewStationScreen::getTabContainer()
{
    return main_panel;
}

void CrewStationScreen::addStationTab(GuiElement* element, ECrewPosition position, string name, string icon)
{
    CrewTabInfo info;
    tileViewport();
    element->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info.position = position;
    info.element = element;

    info.button = new GuiToggleButton(button_strip, "STATION_BUTTON_" + name, name, [this, element](bool value) {
        showTab(element);
        button_strip->hide();
    });
    info.button->setIcon(icon);
    info.button->setPosition(0, tabs.size() * 50, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);

    if (tabs.size() == 0)
    {
        current_position = position;
        element->show();
        info.button->setValue(true);
        select_station_button->setText(name);
        select_station_button->setIcon(icon);

        string keyboard_category = "";

        for (auto binding : sp::io::Keybinding::listAllByCategory(info.button->getText()))
            keyboard_category += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";

        keyboard_help->setText(keyboard_general + keyboard_category);
    }else{
        element->hide();
        info.button->setValue(false);
    }

    tabs.push_back(info);
}

void CrewStationScreen::finishCreation()
{
    select_station_button->moveToFront();
    button_strip->moveToFront();
    button_strip->setSize(button_strip->getSize().x, 50 * tabs.size());

    message_frame->moveToFront();

    new GuiIndicatorOverlays(main_panel);
    new GuiNoiseOverlay(main_panel);
    new GuiShipDestroyedPopup(this);

    if (tabs.size() < 2)
        select_station_button->hide();

    keyboard_help->moveToFront();
}

void CrewStationScreen::update(float delta)
{
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        soundManager->stopMusic();
        impulse_sound->stop();
        disconnectFromServer();
        returnToMainMenu(getRenderLayer());
        return;
    }

    if (keys.escape.getDown())
    {
        if (PreferencesManager::get("autoconnect").toInt())
        {
            LOG(INFO) << "You hit escape and want out! but you'll be back, you will see, all your base will belong to me.";
        }
        else {
            destroy();
            soundManager->stopMusic();
            impulse_sound->stop();
            returnToShipSelection(getRenderLayer());
        }
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

    if (viewport)
    {
        // Responsively show/hide the 3D viewport.
        if (getRect().size.x < 1250)
        {
            viewport->hide();
            main_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
        else {
            viewport->show();
            tileViewport();
        }
    }
    else
    {
        main_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    

    if (my_spaceship)
    {
        // Show custom ship function messages.
        message_frame->hide();

        for(PlayerSpaceship::CustomShipFunction& csf : my_spaceship->custom_functions)
        {
            if (csf.crew_position == current_position && csf.type == PlayerSpaceship::CustomShipFunction::Type::Message)
            {
                message_frame->show();
                message_text->setText(csf.caption);
                break;
            }
        }

        // Update the impulse engine sound.
        impulse_sound->update(delta);
    } else {
        // If we're not the player ship (ie. we exploded), stop playing the
        // impulse engine sound.
        impulse_sound->stop();
    }

    if (keys.next_station.getDown())
        showNextTab(1);
    else if (keys.prev_station.getDown())
        showNextTab(-1);
    else if (keys.station_helms.getDown())
        showTab(findTab(getCrewPositionName(helmsOfficer)));
    else if (keys.station_weapons.getDown())
        showTab(findTab(getCrewPositionName(weaponsOfficer)));
    else if (keys.station_engineering.getDown())
        showTab(findTab(getCrewPositionName(engineering)));
    else if (keys.station_science.getDown())
        showTab(findTab(getCrewPositionName(scienceOfficer)));
    else if (keys.station_relay.getDown())
        showTab(findTab(getCrewPositionName(relayOfficer)));
}

void CrewStationScreen::showNextTab(int offset)
{
    int current = 0;

    for(unsigned int n=0; n<tabs.size(); n++)
    {
        if (tabs[n].element->isVisible())
            current = n;
    }

    int next = (current + offset + tabs.size()) % tabs.size();

    showTab(tabs[next].element);
}

void CrewStationScreen::showTab(GuiElement* element)
{
    if (!element)
        return;

    for(CrewTabInfo& info : tabs)
    {
        if (info.element == element)
        {
            current_position = info.position;
            info.element->show();
            info.button->setValue(true);
            select_station_button->setText(info.button->getText());
            select_station_button->setIcon(info.button->getIcon());

            string keyboard_category = "";

            for (auto binding : sp::io::Keybinding::listAllByCategory(info.button->getText()))
                keyboard_category += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";

            keyboard_help->setText(keyboard_general + keyboard_category);
        } else {
            info.element->hide();
            info.button->setValue(false);
        }
    }
}

GuiElement* CrewStationScreen::findTab(string name)
{
    for(CrewTabInfo& info : tabs)
    {
        if (info.button->getText() == name)
            return info.element;
    }

    return nullptr;
}

string CrewStationScreen::listHotkeysLimited(string station)
{
    string ret = "";
    keyboard_general = "";
    
    for (auto binding : sp::io::Keybinding::listAllByCategory("General"))
        if (binding->getLabel() == "Switch to next crew station" || binding->getLabel() =="Switch to previous crew station" || binding->getLabel() == "Switch crew station")
            keyboard_general += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";

    if (station == "Tactical")
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory("Helms"))
            ret += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";
        for (auto binding : sp::io::Keybinding::listAllByCategory("Weapons"))
        {
            if (binding->getLabel() != "Toggle shields")
                ret += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";
        }
    } else if (station == "Engineering+") {
        for (auto binding : sp::io::Keybinding::listAllByCategory("Engineering"))
            ret += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";
        for (auto binding : sp::io::Keybinding::listAllByCategory("Weapons"))
        {
            if (binding->getLabel() == "Toggle shields")
                ret += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";
        }
    }

    //    -- not yet used --
    //    else if (station == "Operations")
    //        return ret;
    //    ----

    else if (station == "Single Pilot")
    {
        for (auto binding : sp::io::Keybinding::listAllByCategory("Helms"))
            ret += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";
        for (auto binding : sp::io::Keybinding::listAllByCategory("Weapons"))
            ret += binding->getLabel() + ":\t" + binding->getHumanReadableKeyName(0) + "\n";
    }

    return ret;
}

void CrewStationScreen::tileViewport()
{
    if (!viewport)
        return;

    if (current_position == singlePilot)
    {
        main_panel->setSize(1000, GuiElement::GuiSizeMax);
        main_panel->layout.fill_width = false;
        viewport->setPosition(1000, 0, sp::Alignment::TopLeft);
    } else {
        main_panel->setSize(1200, GuiElement::GuiSizeMax);
        main_panel->layout.fill_width = false;
        viewport->setPosition(1200, 0, sp::Alignment::TopLeft);
    }
}
