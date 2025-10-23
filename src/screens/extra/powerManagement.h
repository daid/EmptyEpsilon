#pragma once

#include "gui/gui2_overlay.h"
#include "components/shipsystem.h"

class GuiArrow;
class GuiCustomShipFunctions;
class GuiKeyValueDisplay;
class GuiLabel;
class GuiPanel;
class GuiProgressbar;
class GuiSlider;

class PowerManagementScreen : public GuiOverlay
{
private:
    glm::vec2 view_size;
    int active_system_count;
    GuiElement* status_bar;
    GuiKeyValueDisplay* energy_display;
    GuiProgressbar* energy_capacity_gauge;
    GuiArrow* energy_delta_arrow;
    GuiKeyValueDisplay* coolant_display;
    GuiProgressbar* coolant_distribution_gauge;
    GuiElement* systems_grid;
    GuiCustomShipFunctions* custom_functions;

    constexpr static int layout_margin = 20;
    constexpr static float status_bar_height = 100.0f;
    constexpr static float custom_functions_width = 250.0f;
    constexpr static glm::u8vec3 coolant_color{32, 128, 128};
    constexpr static glm::u8vec4 coolant_color_foreground{coolant_color, 128};
    constexpr static glm::u8vec4 coolant_color_background{coolant_color, 255};
    constexpr static glm::u8vec3 energy_color{192, 192, 32};
    constexpr static glm::u8vec4 energy_color_background{energy_color, 255};

    glm::vec2 panel_size;
    float previous_energy_level;
    float average_energy_delta;
    float previous_energy_measurement;
    ShipSystem::Type selected_system;

    class SystemPanel
    {
    public:
        SystemPanel()
        : container(nullptr), system_label(nullptr), system_container_sliders(nullptr), power_control(nullptr), power_slider(nullptr), power_bar(nullptr), coolant_control(nullptr), coolant_slider(nullptr), coolant_bar(nullptr), heat_bar(nullptr)
        {}
        GuiPanel* container;
        GuiKeyValueDisplay* system_label;
        GuiElement* system_container_sliders;
        GuiLabel* power_label;
        GuiElement* power_control;
        GuiSlider* power_slider;
        GuiProgressbar* power_bar;
        GuiLabel* coolant_label;
        GuiElement* coolant_control;
        GuiSlider* coolant_slider;
        GuiProgressbar* coolant_bar;
        GuiLabel* heat_label;
        GuiArrow* heat_arrow;
        GuiProgressbar* heat_bar;
    };
    SystemPanel systems[ShipSystem::COUNT];
    std::vector<GuiElement*> systems_rows;
    bool set_power_active[ShipSystem::COUNT] = {false};
    bool set_coolant_active[ShipSystem::COUNT] = {false};
public:
    PowerManagementScreen(GuiContainer* owner);

    void onDraw(sp::RenderTarget& target) override;
    bool populateSystemPanel(int system_index, GuiElement* systems_row);
    virtual void onUpdate() override;
};
