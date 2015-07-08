#ifndef SCIENCE_SCREEN_H
#define SCIENCE_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2.h"

class GuiRadarView;
class GuiKeyValueDisplay;
class GuiFrequencyCurve;

class ScienceScreen : public GuiOverlay
{
private:
    TargetsContainer targets;
    GuiRadarView* radar;
    GuiKeyValueDisplay* info_callsign;
    GuiKeyValueDisplay* info_distance;
    GuiKeyValueDisplay* info_heading;
    GuiKeyValueDisplay* info_relspeed;

    GuiKeyValueDisplay* info_faction;
    GuiKeyValueDisplay* info_type;
    GuiKeyValueDisplay* info_shields;
    GuiFrequencyCurve* info_shield_frequency;
    GuiFrequencyCurve* info_beam_frequency;
public:
    ScienceScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//SCIENCE_SCREEN_H
