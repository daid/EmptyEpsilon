#include "crewStationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "preferenceManager.h"

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
        for(CrewTabInfo& info : tabs)
        {
            if (info.element == element)
            {
                info.element->show();
                info.button->setValue(true);
                select_station_button->setText(info.button->getText());
                select_station_button->setIcon(info.button->getIcon());
            }else{
                info.element->hide();
                info.button->setValue(false);
            }
        }
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

void CrewStationScreen::onKey(sf::Keyboard::Key key, int unicode)
{
    switch(key)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        soundManager->stopMusic();
        returnToShipSelection();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}
