#pragma once

#include "gui/gui2_element.h"

class GuiRadarView;
class GuiThemeStyle;

// Class for drawing the Science Bands (red, green, blue) around the Radar for the Science Station
class RawScannerDataRadarOverlay : public GuiElement
{
public:
    RawScannerDataRadarOverlay(GuiRadarView* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
private:
    GuiRadarView* radar;

    const GuiThemeStyle* electrical_band_style;
    const GuiThemeStyle* biological_band_style;
    const GuiThemeStyle* gravitational_band_style;
};
