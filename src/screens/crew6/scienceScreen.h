#ifndef SCIENCE_SCREEN_H
#define SCIENCE_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"
#include "spaceObjects/scanProbe.h"

class GuiListbox;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiFrequencyCurve;
class GuiScrollText;
class GuiButton;
class GuiToggleButton;
class GuiSlider;
class GuiLabel;
class DatabaseViewComponent;

class ScienceScreen : public GuiOverlay
{
protected:
    GuiElement* radar_view;
    DatabaseViewComponent* database_view;

    TargetsContainer targets;
    GuiRadarView* science_radar;
    GuiRadarView* probe_radar;
    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;
    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_distance;
    GuiKeyValueDisplay* info_heading;
    GuiKeyValueDisplay* info_relspeed;

    GuiKeyValueDisplay* info_faction;
    GuiKeyValueDisplay* info_type;
    GuiButton* info_type_button;
    GuiKeyValueDisplay* info_shields;
    GuiKeyValueDisplay* info_hull;
    GuiScrollText* info_description;
    GuiFrequencyCurve* info_shield_frequency;
    GuiFrequencyCurve* info_beam_frequency;
    GuiKeyValueDisplay* info_system[SYS_COUNT];

    GuiToggleButton* probe_view_button;
    P<ScanProbe> observation_point;
    GuiListbox* view_mode_selection;
public:
    ScienceScreen(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//SCIENCE_SCREEN_H
