#ifndef GUI_SCANNING_DIALOG_H
#define GUI_SCANNING_DIALOG_H

#include "gui/gui2.h"
#include "signalQualityIndicator.h"

class GuiScanningDialog : public GuiElement
{
private:
    static constexpr int max_sliders = 4;
    static constexpr float lock_delay = 2.0f;

    GuiBox* box;
    GuiLabel* signal_label;
    GuiLabel* locked_label;
    GuiSignalQualityIndicator* signal_quality;
    GuiSlider* sliders[max_sliders];
    GuiButton* cancel_button;
    
    float target[max_sliders];
    bool locked;
    float lock_start_time;
    int scan_depth;
public:
    GuiScanningDialog(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window);
    
    void setupParameters();
    void updateSignal();
};

#endif//GUI_SCANNING_DIALOG_H
