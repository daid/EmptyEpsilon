#ifndef SCIENCE_SCREEN_H
#define SCIENCE_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"
#include "spaceObjects/scanProbe.h"

class GuiRadarView;
class GuiKeyValueDisplay;
class GuiFrequencyCurve;
class GuiScrollText;
class GuiToggleButton;
class RawScannerDataRadarOverlay;

class ScienceScreen : public GuiOverlay
{
protected:
    GuiElement* radar_view;
    RawScannerDataRadarOverlay* raw_scanner_data_overlay;
    GuiElement* database_view;

    TargetsContainer targets;
    GuiRadarView* science_radar;
    GuiRadarView* probe_radar;
    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_distance;
    GuiKeyValueDisplay* info_heading;
    GuiKeyValueDisplay* info_relspeed;

    GuiKeyValueDisplay* info_faction;
    GuiKeyValueDisplay* info_type;
    GuiKeyValueDisplay* info_shields;
    GuiScrollText* info_description;
    GuiFrequencyCurve* info_shield_frequency;
    GuiFrequencyCurve* info_beam_frequency;
    GuiKeyValueDisplay* info_system[SYS_COUNT];

    GuiToggleButton* probe_view_button;
    P<ScanProbe> observation_point;
public:
    ScienceScreen(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//SCIENCE_SCREEN_H
