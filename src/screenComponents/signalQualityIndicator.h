#ifndef SIGNAL_QUALITY_INDICATOR_H
#define SIGNAL_QUALITY_INDICATOR_H

#include <math.h>

#include "gui/gui2_element.h"

class GuiSignalQualityIndicator : public GuiElement
{
    sf::Clock clock;
    float max_amp;
    float target_period;
    float error_noise;
    float error_period;
    float error_phase;
    bool show_red;
    bool show_green;
    bool show_blue;
public:
    GuiSignalQualityIndicator(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);
    
    void setMaxAmp(float f) { max_amp = std::min(fabsf(f), 1.0f); }
    void setNoiseError(float f) { error_noise = std::min(fabsf(f), 1.0f); }
    void setPeriodError(float f) { error_period = std::min(fabsf(f), 1.0f); }
    void setPhaseError(float f) { error_phase = std::min(fabsf(f), 1.0f); }

    GuiSignalQualityIndicator* showRed(bool show) { show_red = show; return this; }
    GuiSignalQualityIndicator* showGreen(bool show) { show_green = show; return this; }
    GuiSignalQualityIndicator* showBlue(bool show) { show_blue = show; return this; }
};

#endif//SIGNAL_QUALITY_INDICATOR_H
