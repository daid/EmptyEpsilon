#ifndef POWER_MANAGEMENT_H
#define POWER_MANAGEMENT_H

#include "gui/gui2_overlay.h"
#include "shipTemplate.h"

class GuiPanel;
class GuiSlider;
class GuiProgressbar;
class GuiKeyValueDisplay;

class PowerManagementScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* coolant_display;

    float previous_energy_measurement;
    float previous_energy_level;
    float average_energy_delta;

    class SystemRow
    {
    public:
        GuiPanel* box;
        GuiSlider* power_slider;
        GuiSlider* coolant_slider;
        GuiProgressbar* heat_bar;
        GuiProgressbar* power_bar;
        GuiProgressbar* coolant_bar;
    };
    SystemRow systems[SYS_COUNT];
public:
    PowerManagementScreen(GuiContainer* owner);
    
    void onDraw(sf::RenderTarget& window) override;
};

#endif//POWER_MANAGEMENT_H
