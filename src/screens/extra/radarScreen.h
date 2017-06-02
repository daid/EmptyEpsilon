#ifndef RADAR_SCREEN_H
#define RADAR_SCREEN_H

#include "gui/gui2_overlay.h"

class GuiRadarView;

class RadarScreen : public GuiOverlay
{
private:
    GuiRadarView* tactical_radar;
    GuiRadarView* science_radar;
    GuiRadarView* relay_radar;
public:
    string type;
    TacticalRadarScreen(GuiContainer* owner, string type);
};

#endif//RADAR_SCREEN_H
