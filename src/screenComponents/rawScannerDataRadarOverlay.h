#ifndef RAW_SCANNER_DATA_RADAR_OVERLAY_H
#define RAW_SCANNER_DATA_RADAR_OVERLAY_H

#include "gui/gui2_element.h"

class GuiRadarView;

// Class for drawing the Science Bands (red, green, blue) around the Radar for the Science Station
class RawScannerDataRadarOverlay : public GuiElement
{
public:
    RawScannerDataRadarOverlay(GuiRadarView* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
private:
    GuiRadarView* radar;
};

#endif//RAW_SCANNER_DATA_RADAR_OVERLAY_H
