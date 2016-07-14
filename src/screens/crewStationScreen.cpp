#include "crewStationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "preferenceManager.h"
#include "playerInfo.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/noiseOverlay.h"
#include "screenComponents/shipDestroyedPopup.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_panel.h"

CrewStationScreen::CrewStationScreen()
{
    select_station_button = new GuiButton(this, "", "", [this]()
    {
        button_strip->show();
    });
    select_station_button->setPosition(-20, 20, ATopRight)->setSize(250, 50);

    button_strip = new GuiPanel(this, "");
    button_strip->setPosition(-20, 20, ATopRight)->setSize(250, 50);
    button_strip->hide();

    keyboard_help = new GuiHelpOverlay(this, "Keyboard Shortcuts");

    for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory("General"))
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
}

void CrewStationScreen::addStationTab(GuiElement* element, string name, string icon)
{
    CrewTabInfo info;

    element->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    info.element = element;

    info.button = new GuiToggleButton(button_strip, "STATION_BUTTON_" + name, name, [this, element](bool value) {
        showTab(element);
        button_strip->hide();
    });
    info.button->setIcon(icon);
    info.button->setPosition(0, tabs.size() * 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);

    if (tabs.size() == 0)
    {
        element->show();
        info.button->setValue(true);
        select_station_button->setText(name);
        select_station_button->setIcon(icon);

        string keyboard_category = "";

        for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory(info.button->getText()))
            keyboard_category += shortcut.second + ":\t" + shortcut.first + "\n";

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

    new GuiIndicatorOverlays(this);
    new GuiNoiseOverlay(this);
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
        disconnectFromServer();
        returnToMainMenu();
        return;
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
        else if (key.hotkey == "HELMS_STATION")
            showTab(findTab(getCrewPositionName(helmsOfficer)));
        else if (key.hotkey == "WEAPONS_STATION")
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
        returnToShipSelection();
        break;
    case sf::Keyboard::Slash:
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
            info.element->show();
            info.button->setValue(true);
            select_station_button->setText(info.button->getText());
            select_station_button->setIcon(info.button->getIcon());

            string keyboard_category = "";

            for (std::pair<string, string> shortcut : hotkeys.listHotkeysByCategory(info.button->getText()))
                keyboard_category += shortcut.second + ":\t" + shortcut.first + "\n";

            keyboard_help->setText(keyboard_general + keyboard_category);
        }else{
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
