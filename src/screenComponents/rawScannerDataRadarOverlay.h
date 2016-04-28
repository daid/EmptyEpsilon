#ifndef RAW_SCANNER_DATA_RADAR_OVERLAY_H
#define RAW_SCANNER_DATA_RADAR_OVERLAY_H

#include "gui/gui2_element.h"

class RawScannerDataRadarOverlay : public GuiElement
{
public:
    RawScannerDataRadarOverlay(GuiContainer* owner, string id, float distance);

    virtual void onDraw(sf::RenderTarget& window) override;
private:
    float distance;
};

#endif//RAW_SCANNER_DATA_RADAR_OVERLAY_H
