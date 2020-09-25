#ifndef SCANNING_DIALOG_H
#define SCANNING_DIALOG_H

#include "gui/gui2_element.h"
#include "signalQualityIndicator.h"
#include "gameGlobalInfo.h"

class GuiPanel;
class GuiLabel;
class GuiSlider;
class GuiButton;

class GuiScanningDialog : public GuiElement
{
private:
    static constexpr int max_sliders = 4;
    static constexpr float lock_delay = 2.0f;

    GuiPanel* box;
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

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onJoystickAxis(const AxisAction& axisAction) override;

    void setupParameters();
    void updateSignal();
};

#endif//SCANNING_DIALOG_H
