#include "crewStationScreen.h"
#include "menus/shipSelectionScreen.h"

#include "screenComponents/indicatorOverlays.h"
#include "screenComponents/shipDestroyedPopup.h"

CrewStationScreen::CrewStationScreen()
{
    button_strip = new GuiAutoLayout(this, "BUTTON_STRIP", GuiAutoLayout::LayoutHorizontalLeftToRight);
    button_strip->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, 35);
}

void CrewStationScreen::addStationTab(GuiElement* element, string name)
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
            }else{
                info.element->hide();
                info.button->setValue(false);
            }
        }
    });
    info.button->setTextSize(20)->setSize(200, 35);
    if (tabs.size() == 0)
    {
        element->show();
        info.button->setValue(true);
    }else{
        element->hide();
        info.button->setValue(false);
    }
    tabs.push_back(info);
}

void CrewStationScreen::finishCreation()
{
    button_strip->moveToFront();
    new GuiIndicatorOverlays(this);
    new GuiShipDestroyedPopup(this);
    if (tabs.size() < 2)
        button_strip->hide();
}

void CrewStationScreen::onKey(sf::Keyboard::Key key, int unicode)
{
    switch(key)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        new ShipSelectionScreen();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}
