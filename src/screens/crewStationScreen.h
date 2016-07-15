#ifndef CREW_STATION_SCREEN_H
#define CREW_STATION_SCREEN_H

#include "engine.h"
#include "threatLevelEstimate.h"

#include "gui/gui2_canvas.h"

#include "screenComponents/helpOverlay.h"
#include "screenComponents/viewport3d.h"

class GuiButton;
class GuiHelpOverlay;
class GuiPanel;
class GuiToggleButton;

class CrewStationScreen : public GuiCanvas, public Updatable
{
    P<ThreatLevelEstimate> threat_estimate;
private:
    GuiButton* select_station_button;
    GuiPanel* button_strip;
    GuiHelpOverlay* keyboard_help;
    struct CrewTabInfo {
        GuiToggleButton* button;
        GuiElement* element;
    };
    std::vector<CrewTabInfo> tabs;
    string keyboard_general = "";
    void showNextTab(int offset=1);
    void showTab(GuiElement* element);
    GuiElement* findTab(string name);
public:
    CrewStationScreen();
    void addStationTab(GuiElement* element, string name, string icon);
    void finishCreation();
    
    virtual void update(float delta) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif//CREW_STATION_SCREEN_H
