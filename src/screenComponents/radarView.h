#ifndef GUI_RADAR_VIEW_H
#define GUI_RADAR_VIEW_H

#include "gui/gui2.h"

class GuiRadarView : public GuiElement
{
private:
    float distance;
    sf::Vector2f view_position;
    bool long_range;
    bool show_callsigns;
    float range_indicator_step_size;
public:
    GuiRadarView(GuiContainer* owner, string id, float distance);

    virtual void onDraw(sf::RenderTarget& window);

    GuiRadarView* setDistance(float distance) { this->distance = distance; return this; }
    GuiRadarView* setRangeIndicatorStepSize(float step) { range_indicator_step_size = step; return this; }
    GuiRadarView* longRange() { long_range = true; return this; }
    GuiRadarView* shortRange() { long_range = false; return this; }
    GuiRadarView* enableCallsigns() { show_callsigns = true; return this; }
    GuiRadarView* disableCallsigns() { show_callsigns = false; return this; }
private:
    void drawBackground(sf::RenderTarget& window);
    void drawSectorGrid(sf::RenderTarget& window);
    void drawRangeIndicators(sf::RenderTarget& window);
    void drawObjects(sf::RenderTarget& window);
    void drawRadarCutoff(sf::RenderTarget& window);
};

#endif//GUI_RADAR_VIEW_H
