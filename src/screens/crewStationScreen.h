#ifndef CREW_STATION_SCREEN_H
#define CREW_STATION_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/viewport3d.h"

class CrewStationScreen : public GuiCanvas
{
private:
    GuiAutoLayout* button_strip;
    struct CrewTabInfo {
        string name;
        GuiToggleButton* button;
        GuiElement* element;
    };
    std::vector<CrewTabInfo> tabs;
public:
    CrewStationScreen();
    void addStationTab(GuiElement* element, string name);
    void finishCreation();
    
    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//CREW_STATION_SCREEN_H

