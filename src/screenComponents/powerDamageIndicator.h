#pragma once

#include "gui/gui2_element.h"

class GuiThemeStyle;

class GuiPowerDamageIndicator : public GuiElement
{
public:
    GuiPowerDamageIndicator(GuiContainer* owner, string name, ShipSystem::Type system, sp::Alignment icon_align);

    virtual void onDraw(sp::RenderTarget& target) override;

private:
    ShipSystem::Type system;
    float text_size = 30.0f;
    sp::Alignment icon_align;

    glm::vec2 icon_position;
    glm::vec2 icon_offset;
    float icon_size;

    const GuiThemeStyle* overlay_damaged_style;
    const GuiThemeStyle* overlay_docked_style;
    const GuiThemeStyle* overlay_jammed_style;
    const GuiThemeStyle* overlay_hacked_style;
    const GuiThemeStyle* overlay_no_power_style;
    const GuiThemeStyle* overlay_low_energy_style;
    const GuiThemeStyle* overlay_low_power_style;
    const GuiThemeStyle* overlay_overheating_style;

    void drawIcon(sp::RenderTarget& window, string icon_name, glm::u8vec4 color);
};
