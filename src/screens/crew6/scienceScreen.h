#ifndef SCIENCE_SCREEN_H
#define SCIENCE_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"
#include "playerInfo.h"

class GuiListbox;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiFrequencyCurve;
class GuiScrollText;
class GuiButton;
class GuiScanTargetButton;
class GuiToggleButton;
class GuiSelector;
class GuiSlider;
class GuiLabel;
class GuiImage;
class DatabaseViewComponent;
class GuiCustomShipFunctions;

class ScienceScreen : public GuiOverlay
{
public:
    GuiImage* background_gradient;
    GuiOverlay* background_crosses;

    GuiElement* radar_view;
    DatabaseViewComponent* database_view;

    TargetsContainer targets;
    GuiRadarView* science_radar;
    GuiRadarView* probe_radar;
    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;

    GuiSelector* sidebar_selector;
    GuiElement* info_sidebar;
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
    GuiKeyValueDisplay* info_health;
    GuiScrollText* info_description;
    GuiFrequencyCurve* info_shield_frequency;
    GuiFrequencyCurve* info_beam_frequency;
    GuiKeyValueDisplay* info_system[ShipSystem::COUNT];

    GuiToggleButton* probe_view_button;
    sp::ecs::Entity observation_point;
    GuiListbox* view_mode_selection;
public:
    ScienceScreen(GuiContainer* owner, CrewPosition crew_position=CrewPosition::scienceOfficer);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
private:
    //used to judge when to update the UI label and zoom
    float previous_long_range_radar=0;
    float previous_short_range_radar=0;
};

#endif//SCIENCE_SCREEN_H
