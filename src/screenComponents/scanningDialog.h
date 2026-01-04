#pragma once

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
    bool locked = false;
    float lock_start_time = 0.0f;
    int scan_depth = 0;
    std::array<bool, max_sliders> set_active = {false, false, false, false};
    std::pair<int, int> getScanComplexityDepth();
public:
    GuiScanningDialog(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;

    void setupParameters();
    void updateSignal();
    bool isBoxVisible();
};
