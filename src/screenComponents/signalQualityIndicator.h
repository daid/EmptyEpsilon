#pragma once

#include <math.h>

#include "gui/gui2_element.h"
#include "timer.h"

class GuiThemeStyle;

// Class for drawing bands in the Science Station's "Scanning" mini-game
class GuiSignalQualityIndicator : public GuiElement
{
private:
    sp::SystemStopwatch clock;
    float target_period;
    float error_noise = 0.0f;
    float error_period = 0.0f;
    float error_phase = 0.0f;
    const GuiThemeStyle* signalquality_style;
    const GuiThemeStyle* electrical_band_style;
    const GuiThemeStyle* biological_band_style;
    const GuiThemeStyle* gravitational_band_style;
public:
    GuiSignalQualityIndicator(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;

    void setNoiseError(float f) { error_noise = std::min(fabsf(f), 1.0f); }
    void setPeriodError(float f) { error_period = std::min(fabsf(f), 1.0f); }
    void setPhaseError(float f) { error_phase = std::min(fabsf(f), 1.0f); }
};
