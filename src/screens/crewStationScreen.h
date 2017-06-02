#ifndef CREW_STATION_SCREEN_H
#define CREW_STATION_SCREEN_H

#include "engine.h"
#include "threatLevelEstimate.h"
#include "playerInfo.h"

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
public:
    CrewStationScreen();
    void addStationTab(GuiElement* element, ECrewPosition position, string name, string icon);
    void finishCreation();
    
    virtual void update(float delta) override;
    virtual void onHotkey(const HotkeyResult& key) override;
    virtual void onKey(sf::Event::KeyEvent key, int unicode) override;

private:
    GuiButton* select_station_button;
    GuiPanel* button_strip;
    GuiHelpOverlay* keyboard_help;
    GuiPanel* message_frame;
    GuiScrollText* message_text;
    GuiButton* message_close_button;
    
    struct CrewTabInfo {
        GuiToggleButton* button;
        GuiElement* element;
        ECrewPosition position;
    };
    ECrewPosition current_position;
    std::vector<CrewTabInfo> tabs;
    string keyboard_general = "";
    void showNextTab(int offset=1);
    void showTab(GuiElement* element);

    GuiElement* findTab(string name);
    
    string listHotkeysLimited(string station);
};

#endif//CREW_STATION_SCREEN_H
