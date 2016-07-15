#ifndef CREW_STATION_SCREEN_H
#define CREW_STATION_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/viewport3d.h"
#include "threatLevelEstimate.h"

class GuiButton;
class GuiToggleButton;
class GuiPanel;

class CrewStationScreen : public GuiCanvas, public Updatable
{
    P<ThreatLevelEstimate> threat_estimate;
private:
    GuiButton* select_station_button;
    GuiPanel* button_strip;
    struct CrewTabInfo {
        GuiToggleButton* button;
        GuiElement* element;
    };
    std::vector<CrewTabInfo> tabs;
public:
    CrewStationScreen();
    void addStationTab(GuiElement* element, string name, string icon);
    void finishCreation();
    
    virtual void update(float delta) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;

private:
    void showNextTab(int offset=1);
    void showTab(GuiElement* element);
    GuiElement* findTab(string name);
};

#endif//CREW_STATION_SCREEN_H
