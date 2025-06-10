#ifndef CREW_STATION_SCREEN_H
#define CREW_STATION_SCREEN_H

#include <memory>
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
class GuiViewport3D;
class ImpulseSound;

class CrewStationScreen : public GuiCanvas, public Updatable
{
    P<ThreatLevelEstimate> threat_estimate;
public:
    explicit CrewStationScreen(RenderLayer* render_layer, bool with_main_screen);
    virtual void destroy() override;

    GuiContainer* getTabContainer();
    void addStationTab(GuiElement* element, CrewPosition position, string name, string icon);
    void finishCreation();

    virtual void update(float delta) override;

private:
    GuiElement* main_panel;
    GuiViewport3D* viewport{ nullptr };
    GuiButton* select_station_button;
    GuiPanel* button_strip;
    GuiHelpOverlay* keyboard_help;
    GuiPanel* message_frame;
    GuiScrollText* message_text;
    GuiButton* message_close_button;
    std::unique_ptr<ImpulseSound> impulse_sound;

    struct CrewTabInfo {
        GuiToggleButton* button;
        GuiElement* element;
        CrewPosition position;
    };

    CrewPosition current_position = CrewPosition::helmsOfficer;
    std::vector<CrewTabInfo> tabs;
    string keyboard_general = "";
    void showNextTab(int offset=1);
    void showTab(GuiElement* element);
    string populateShortcutsList(CrewPosition position);

    GuiElement* findTab(string name);

    void tileViewport();
};

#endif//CREW_STATION_SCREEN_H
