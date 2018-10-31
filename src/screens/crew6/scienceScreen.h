#ifndef SCIENCE_SCREEN_H
#define SCIENCE_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"
#include "spaceObjects/scanProbe.h"
#include "playerInfo.h"

class GuiListbox;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiFrequencyCurve;
class GuiScrollText;
class GuiAutoLayout;
class GuiButton;
class GuiScanTargetButton;
class GuiToggleButton;
class GuiSelector;
class GuiSlider;
class GuiLabel;
class DatabaseViewComponent;
class GuiCustomShipFunctions;

class ScienceScreen : public GuiOverlay
{
public:
    GuiOverlay* background_gradient;
    GuiOverlay* background_crosses;

    GuiElement* radar_view;
    DatabaseViewComponent* database_view;

    TargetsContainer targets;
    GuiRadarView* science_radar;
    GuiRadarView* probe_radar;
    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;

    GuiSelector* sidebar_selector;
    GuiAutoLayout* info_sidebar;
    GuiCustomShipFunctions* custom_function_sidebar;
    GuiSelector* sidebar_pager;
    GuiScanTargetButton* scan_button;
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
    ScienceScreen(GuiContainer* owner, ECrewPosition crew_position=scienceOfficer);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//SCIENCE_SCREEN_H
