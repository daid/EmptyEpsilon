#ifndef POWER_MANAGEMENT_SCREEN_H
#define POWER_MANAGEMENT_SCREEN_H

#include "gui/gui2_overlay.h"
#include "shipTemplate.h"

class GuiPanel;
class GuiSlider;
class GuiProgressbar;

class PowerManagementScreen : public GuiOverlay
{
private:
    class SystemRow
    {
    public:
        GuiPanel* box;
        GuiSlider* power_slider;
        GuiSlider* coolant_slider;
        GuiProgressbar* heat_bar;
    };
    SystemRow systems[SYS_COUNT];
public:
    PowerManagementScreen(GuiContainer* owner);
    
    void onDraw(sf::RenderTarget& window) override;
};

#endif//POWER_MANAGEMENT_SCREEN_H
