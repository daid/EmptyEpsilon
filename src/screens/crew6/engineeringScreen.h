#ifndef ENGINEERING_SCREEN_H
#define ENGINEERING_SCREEN_H

#include "gui/gui2.h"
#include "shipTemplate.h"

class EngineeringScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* front_shield_display;
    GuiKeyValueDisplay* rear_shield_display;
    GuiSlider* power_slider;
    GuiSlider* coolant_slider;
    
    class SystemRow
    {
    public:
        GuiAutoLayout* layout;
        GuiToggleButton* button;
        GuiProgressbar* damage_bar;
        GuiLabel* damage_label;
        GuiProgressbar* heat_bar;
        GuiArrow* heat_arrow;
        GuiProgressbar* power_bar;
        GuiProgressbar* coolant_bar;
    };
    std::vector<SystemRow> system_rows;
    ESystem selected_system;
public:
    EngineeringScreen(GuiContainer* owner);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//ENGINEERING_SCREEN_H
