#ifndef SCANNING_DIALOG_H
#define SCANNING_DIALOG_H

#include "gui/gui2_element.h"
#include "gui/gui2_slider.h"
#include "signalQualityIndicator.h"
#include "gameGlobalInfo.h"

class GuiPanel;
class GuiLabel;
class GuiSlider;
class GuiButton;

class FrequencySlider : public GuiSlider
{
	using GuiSlider::GuiSlider;
public:
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
	bool mouseDown = false;
	bool mouseHadClick = false;
};

class GuiScanningDialog : public GuiElement
{
private:
    static constexpr int max_sliders = 4;
    static constexpr float lock_delay = 0.5f;

    GuiPanel* box;
    GuiLabel* signal_label;
    GuiLabel* locked_label;
    GuiSignalQualityIndicator* signal_quality;
    FrequencySlider* sliders[max_sliders];
    GuiButton* cancel_button;
    
    float target[max_sliders];
    bool locked;
    float lock_start_time;
    float honing_start_time;
    int scan_depth;
public:
    GuiScanningDialog(GuiContainer* owner, string id);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onJoystickAxis(const AxisAction& axisAction) override;
    
    void setupParameters();
    void updateSignal();
};

#endif//SCANNING_DIALOG_H
