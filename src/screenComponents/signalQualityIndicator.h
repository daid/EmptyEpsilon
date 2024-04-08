#ifndef SIGNAL_QUALITY_INDICATOR_H
#define SIGNAL_QUALITY_INDICATOR_H

#include <math.h>

#include "gui/gui2_element.h"
#include "timer.h"

// Class for drawing bands in the Science Station's "Scanning" mini-game
class GuiSignalQualityIndicator : public GuiElement
{
    sp::SystemStopwatch clock;
    float target_period;
    float error_noise;
    float error_period;
    float error_phase;
public:
    GuiSignalQualityIndicator(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;

    void setNoiseError(float f) { error_noise = std::min(fabsf(f), 1.0f); }
    void setPeriodError(float f) { error_period = std::min(fabsf(f), 1.0f); }
    void setPhaseError(float f) { error_phase = std::min(fabsf(f), 1.0f); }
};

#endif//SIGNAL_QUALITY_INDICATOR_H
