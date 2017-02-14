#ifndef RAW_SCANNER_DATA_RADAR_OVERLAY_H
#define RAW_SCANNER_DATA_RADAR_OVERLAY_H

#include "gui/gui2_element.h"

class GuiRadarView;

class RawScannerDataRadarOverlay : public GuiElement
{
public:
    RawScannerDataRadarOverlay(GuiRadarView* owner, string id, float distance);

    virtual void onDraw(sf::RenderTarget& window) override;
private:
    GuiRadarView* radar;
    float distance;
};

#endif//RAW_SCANNER_DATA_RADAR_OVERLAY_H
