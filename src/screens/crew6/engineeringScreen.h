#ifndef ENGINEERING_SCREEN_H
#define ENGINEERING_SCREEN_H

#include "gui/gui2_overlay.h"
#include "playerInfo.h"

class GuiSelfDestructButton;
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

    GuiSelfDestructButton* self_destruct_button;
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
    ShipSystem::Type selected_system;

    bool set_power_active[ShipSystem::COUNT] = {false};
    bool set_coolant_active[ShipSystem::COUNT] = {false};

    void addSystemEffect(string key, string value);
    void selectSystem(ShipSystem::Type system);

    string toNearbyIntString(float value);
public:
    EngineeringScreen(GuiContainer* owner, CrewPosition crew_position=CrewPosition::engineering);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//ENGINEERING_SCREEN_H
