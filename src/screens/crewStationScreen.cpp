#include "crewStationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "preferenceManager.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

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

CrewStationScreen::CrewStationScreen()
{
    // Create a 3D viewport behind everything, to serve as the right-side panel
    viewport = new GuiViewportMainScreen(this, "3D_VIEW");
    viewport->showCallsigns()->showHeadings()->showSpacedust();
    viewport->setPosition(1200, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    viewport->hide();

    main_panel = new GuiElement(this, "MAIN");
    main_panel->setSize(1200, GuiElement::GuiSizeMax);

    select_station_button = new GuiButton(main_panel, "", "", [this]()
    {
        button_strip->show();
    });
    select_station_button->setPosition(-20, 20, ATopRight)->setSize(250, 50);

    button_strip = new GuiPanel(main_panel, "");
    button_strip->setPosition(-20, 20, ATopRight)->setSize(250, 50);
    button_strip->hide();

    message_frame = new GuiPanel(main_panel, "");
    message_frame->setPosition(0, 0, ATopCenter)->setSize(900, 230)->hide();

    message_text = new GuiScrollText(message_frame, "", "");
    message_text->setTextSize(20)->setPosition(20, 20, ATopLeft)->setSize(900 - 40, 200 - 40);
    message_close_button = new GuiButton(message_frame, "", "Close", [this]() {
        if (my_spaceship)
        {
            for(PlayerSpaceship::CustomShipFunction& csf : my_spaceship->custom_functions)
            {
                if (csf.crew_position == current_position && csf.type == PlayerSpaceship::CustomShipFunction::Type::Message)
                {
                    my_spaceship->commandCustomFunction(csf.name, nullptr);
                    break;
                }
            }
        }
    });
    message_close_button->setTextSize(30)->setPosition(-20, -20, ABottomRight)->setSize(300, 30);

    keyboard_help = new GuiHelpOverlay(main_panel, "Keyboard Shortcuts");

    for (std::pair<string, string> shortcut : listControlsByCategory("General"))
        keyboard_general += shortcut.second + ":\t" + shortcut.first + "\n";

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
    info.button->setPosition(0, tabs.size() * 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);

    if (tabs.size() == 0)
    {
        current_position = position;
        element->show();
        info.button->setValue(true);
        select_station_button->setText(name);
        select_station_button->setIcon(icon);

        string keyboard_category = "";

        for (std::pair<string, string> shortcut : listControlsByCategory(info.button->getText()))
            keyboard_category += shortcut.second + ":\t" + shortcut.first + "\n";
        if (keyboard_category == "")   // special hotkey combination for crew1 and crew4 screens
            keyboard_category = listHotkeysLimited(info.button->getText());

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
        returnToMainMenu();
        return;
    }

    // Responsively show/hide the 3D viewport.
    if (!main_screen_enabled || viewport->getRect().width < viewport->getRect().height / 3.0f)
    {
        viewport->hide();
        main_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    } else {
        viewport->show();
        tileViewport();
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
}

void CrewStationScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "GENERAL")
    {
        if (key.hotkey == "NEXT_STATION")
            showNextTab(1);
        else if (key.hotkey == "PREV_STATION")
            showNextTab(-1);
        else if (key.hotkey == "STATION_HELMS")
            showTab(findTab(getCrewPositionName(helmsOfficer)));
        else if (key.hotkey == "STATION_WEAPONS")
            showTab(findTab(getCrewPositionName(weaponsOfficer)));
        else if (key.hotkey == "STATION_ENGINEERING")
            showTab(findTab(getCrewPositionName(engineering)));
        else if (key.hotkey == "STATION_SCIENCE")
            showTab(findTab(getCrewPositionName(scienceOfficer)));
        else if (key.hotkey == "STATION_RELAY")
            showTab(findTab(getCrewPositionName(relayOfficer)));
    }
}

void CrewStationScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        soundManager->stopMusic();
        impulse_sound->stop();
        returnToShipSelection();
        break;
    case sf::Keyboard::Slash:
    case sf::Keyboard::F1:
        // Toggle keyboard help.
        keyboard_help->frame->setVisible(!keyboard_help->frame->isVisible());
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
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

            for (std::pair<string, string> shortcut : listControlsByCategory(info.button->getText()))
                keyboard_category += shortcut.second + ":\t" + shortcut.first + "\n";
        if (keyboard_category == "")    // special hotkey combination for crew1 and crew4 screens
        keyboard_category = listHotkeysLimited(info.button->getText());

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

    for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory("General"))
        if (shortcut.first == "Switch to next crew station" || shortcut.first =="Switch to previous crew station" || shortcut.first == "Switch crew station")
            keyboard_general += shortcut.second + ":\t" + shortcut.first + "\n";

    if (station == "Tactical")
    {
        for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory("Helms"))
           ret += shortcut.second + ":\t" + shortcut.first + "\n";
        for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory("Weapons"))
        {
            if (shortcut.first != "Toggle shields")
                ret += shortcut.second + ":\t" + shortcut.first + "\n";
        }
    } else if (station == "Engineering+") {
        for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory("Engineering"))
            ret += shortcut.second + ":\t" + shortcut.first + "\n";
        for (std::pair<string, string> shortcut : listControlsByCategory("Weapons"))
        {
            if (shortcut.first == "Toggle shields")
                ret += shortcut.second + ":\t" + shortcut.first + "\n";
        }
    }

    //    -- not yet used --
    //    else if (station == "Operations")
    //        return ret;
    //    ----

    else if (station == "Single Pilot")
    {
        for (std::pair<string, string> shortcut : listControlsByCategory("Helms"))
            ret += shortcut.second + ":\t" + shortcut.first + "\n";
        for (std::pair<string, string> shortcut : listControlsByCategory("Weapons"))
            ret += shortcut.second + ":\t" + shortcut.first + "\n";
    }

    return ret;
}

void CrewStationScreen::tileViewport()
{
    if (current_position == singlePilot)
    {
        main_panel->setSize(1000, GuiElement::GuiSizeMax);
        viewport->setPosition(1000, 0, ATopLeft);
    } else {
        main_panel->setSize(1200, GuiElement::GuiSizeMax);
        viewport->setPosition(1200, 0, ATopLeft);
    }
}

std::vector<std::pair<string, string>> CrewStationScreen::listControlsByCategory(string category){
    std::vector<std::pair<string, string>> hotkeyControls = hotkeys.listHotkeysByCategory(category);
    std::vector<std::pair<string, string>> joystickControls = joystick.listJoystickByCategory(category);
    hotkeyControls.insert(hotkeyControls.end(), joystickControls.begin(), joystickControls.end());
    return hotkeyControls;
}
