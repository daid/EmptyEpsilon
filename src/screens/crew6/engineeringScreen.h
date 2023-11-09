#ifndef ENGINEERING_SCREEN_H
#define ENGINEERING_SCREEN_H

#include "gui/gui2_overlay.h"
#include "shipTemplate.h"
#include "playerInfo.h"

class GuiKeyValueDisplay;
class GuiLabel;
class GuiSlider;
class GuiImage;
class GuiArrow;
class GuiToggleButton;
class GuiProgressbar;
class GuiProgressSlider;

class EngineeringScreen : public GuiOverlay
{
private:
    GuiOverlay* background_crosses;

    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* front_shield_display;
    GuiKeyValueDisplay* rear_shield_display;
    GuiKeyValueDisplay* coolant_display;
    GuiLabel* power_label;
    GuiSlider* power_slider;
    GuiLabel* coolant_label;
    GuiSlider* coolant_slider;
    GuiProgressbar* coolant_remaining_bar;

    class SystemRow
    {
    public:
        GuiElement* row;
        GuiToggleButton* button;
        GuiProgressbar* damage_bar;
        GuiImage* damage_icon;
        GuiLabel* damage_label;
        GuiProgressbar* heat_bar;
        GuiArrow* heat_arrow;
        GuiImage* heat_icon;
        GuiProgressSlider* power_bar;
        GuiProgressSlider* coolant_bar;
        GuiImage* coolant_max_indicator;
    };
    std::vector<SystemRow> system_rows;
    GuiElement* system_effects_container;
    std::vector<GuiKeyValueDisplay*> system_effects;
    unsigned int system_effects_index;
    ESystem selected_system;

    float previous_energy_measurement;
    float previous_energy_level;
    float average_energy_delta;

    void addSystemEffect(string key, string value);
    void selectSystem(ESystem system);

    string toNearbyIntString(float value);
public:
    EngineeringScreen(GuiContainer* owner, ECrewPosition crew_position=engineering);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//ENGINEERING_SCREEN_H
