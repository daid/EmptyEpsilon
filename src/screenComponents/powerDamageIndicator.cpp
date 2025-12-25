#include "playerInfo.h"
#include "i18n.h"
#include "powerDamageIndicator.h"
#include "systems/warpsystem.h"
#include "components/reactor.h"
#include "components/docking.h"
#include "components/shipsystem.h"
#include "main.h"
#include "gui/theme.h"

GuiPowerDamageIndicator::GuiPowerDamageIndicator(GuiContainer* owner, string name, ShipSystem::Type system, sp::Alignment icon_align)
: GuiElement(owner, name), system(system), icon_align(icon_align)
{
    // TODO: Also define icons in GuiThemeStyle
    overlay_damaged_style = theme->getStyle("overlay.damaged");
    overlay_docked_style = theme->getStyle("overlay.docked");
    overlay_jammed_style = theme->getStyle("overlay.jammed");
    overlay_hacked_style = theme->getStyle("overlay.hacked");
    overlay_no_power_style = theme->getStyle("overlay.no_power");
    overlay_low_energy_style = theme->getStyle("overlay.low_energy");
    overlay_low_power_style = theme->getStyle("overlay.low_power");
    overlay_overheating_style = theme->getStyle("overlay.overheating");
}

void GuiPowerDamageIndicator::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship) return;

    auto reactor = my_spaceship.getComponent<Reactor>();
    auto sys = ShipSystem::get(my_spaceship, system);
    if (!sys) return;
    auto port = my_spaceship.getComponent<DockingPort>();

    glm::u8vec4 color;
    string display_text;

    float power = sys->power_level;
    float health = sys->health;
    float heat = sys->heat_level;
    float hacked_level = sys->hacked_level;
    if (system == ShipSystem::Type::FrontShield)
    {
        if (auto rear = ShipSystem::get(my_spaceship, ShipSystem::Type::RearShield))
        {
            power = std::max(power, rear->power_level);
            health = std::max(health, rear->health);
            heat = std::max(heat, rear->heat_level);
            hacked_level = std::max(hacked_level, rear->hacked_level);
        }
    }
    if (health <= 0.0f)
    {
        color = overlay_damaged_style->get(getState()).color;
        display_text = tr("systems", "DAMAGED");
    }else if ((system == ShipSystem::Type::Warp || system == ShipSystem::Type::JumpDrive || system == ShipSystem::Type::Impulse) && (port && port->state != DockingPort::State::NotDocking))
    {
        color = overlay_docked_style->get(getState()).color;
        display_text = port->state == DockingPort::State::Docking ? tr("systems", "DOCKING") :  tr("systems", "DOCKED");
    }else if ((system == ShipSystem::Type::Warp || system == ShipSystem::Type::JumpDrive) && WarpSystem::isWarpJammed(my_spaceship))
    {
        color = overlay_jammed_style->get(getState()).color;
        display_text = tr("systems", "JAMMED");
    }else if (power == 0.0f)
    {
        color = overlay_no_power_style->get(getState()).color;
        display_text = tr("systems", "NO POWER");
    }else if (reactor && reactor->energy < 10.0f)
    {
        color = overlay_low_energy_style->get(getState()).color;
        display_text = tr("systems", "LOW ENERGY");
    }else if (power < 0.3f)
    {
        color = overlay_low_power_style->get(getState()).color;
        display_text = tr("systems", "LOW POWER");
    }else if (heat > 0.90f)
    {
        color = overlay_overheating_style->get(getState()).color;
        display_text = tr("systems", "OVERHEATING");
    }else if (hacked_level > 0.1f)
    {
        color = overlay_hacked_style->get(getState()).color;
        display_text = tr("systems", "HACKED");
    }else{
        return;
    }
    renderer.drawStretched(rect, "gui/widget/damagePowerOverlay.png", color);

    if (rect.size.y > rect.size.x)
        renderer.drawText(rect, display_text, sp::Alignment::Center, text_size, bold_font, color, sp::Font::FlagVertical);
    else
        renderer.drawText(rect, display_text, sp::Alignment::Center, text_size, bold_font, color);

    icon_size = std::min(rect.size.x, rect.size.y) * 0.8f;

    switch(icon_align)
    {
    case sp::Alignment::CenterLeft:
        icon_position = glm::vec2(rect.position.x - icon_size / 2.0f, rect.position.y + rect.size.y / 2.0f);
        icon_offset = glm::vec2(-icon_size, 0);
        break;
    case sp::Alignment::CenterRight:
        icon_position = glm::vec2(rect.position.x + rect.size.x + icon_size / 2.0f, rect.position.y + rect.size.y / 2.0f);
        icon_offset = glm::vec2(icon_size, 0);
        break;
    case sp::Alignment::BottomRight:
        icon_position = glm::vec2(rect.position.x + rect.size.x + icon_size / 2.0f, rect.position.y + rect.size.y - icon_size / 2.0f);
        icon_offset = glm::vec2(0, -icon_size);
        break;
    case sp::Alignment::BottomLeft:
        icon_position = glm::vec2(rect.position.x - icon_size / 2.0f, rect.position.y + rect.size.y - icon_size / 2.0f);
        icon_offset = glm::vec2(0, -icon_size);
        break;
    case sp::Alignment::TopRight:
        icon_position = glm::vec2(rect.position.x + rect.size.x + icon_size / 2.0f, rect.position.y + icon_size / 2.0f);
        icon_offset = glm::vec2(0, icon_size);
        break;
    case sp::Alignment::TopLeft:
        icon_position = glm::vec2(rect.position.x - icon_size / 2.0f, rect.position.y + icon_size / 2.0f);
        icon_offset = glm::vec2(0, icon_size);
        break;
    case sp::Alignment::TopCenter:
        icon_position = glm::vec2(rect.position.x + rect.size.x / 2.0f, rect.position.y - icon_size / 2.0f);
        icon_offset = glm::vec2(0, -icon_size);
        break;
    case sp::Alignment::BottomCenter:
        icon_position = glm::vec2(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y + icon_size / 2.0f);
        icon_offset = glm::vec2(0, icon_size);
        break;
    case sp::Alignment::Center:
        icon_position = glm::vec2(rect.position.x + rect.size.x / 2.0f, rect.position.y + rect.size.y / 2.0f);
        icon_offset = glm::vec2(0, 0);
        break;
    }

    if (health <= 0.0f)
        drawIcon(renderer, overlay_damaged_style->get(getState()).texture, overlay_damaged_style->get(getState()).color);

    if ((system == ShipSystem::Type::Warp || system == ShipSystem::Type::JumpDrive || system == ShipSystem::Type::Impulse) && (port && port->state != DockingPort::State::NotDocking))
        drawIcon(renderer, overlay_docked_style->get(getState()).texture, overlay_docked_style->get(getState()).color);
    else if ((system == ShipSystem::Type::Warp || system == ShipSystem::Type::JumpDrive) && WarpSystem::isWarpJammed(my_spaceship))
        drawIcon(renderer, overlay_jammed_style->get(getState()).texture, overlay_jammed_style->get(getState()).color);

    if (power == 0.0f)
        drawIcon(renderer, overlay_no_power_style->get(getState()).texture, overlay_no_power_style->get(getState()).color);
    else if (power < 0.3f)
        drawIcon(renderer, overlay_low_power_style->get(getState()).texture, overlay_low_power_style->get(getState()).color);

    if (reactor && reactor->energy < 10.0f)
        drawIcon(renderer, overlay_low_energy_style->get(getState()).texture, overlay_low_energy_style->get(getState()).color);

    if (heat > 0.90f)
        drawIcon(renderer, overlay_overheating_style->get(getState()).texture, overlay_overheating_style->get(getState()).color);
}

void GuiPowerDamageIndicator::drawIcon(sp::RenderTarget& renderer, string icon_name, glm::u8vec4 color)
{
    renderer.drawSprite(icon_name, icon_position, icon_size, color);
    icon_position += icon_offset;
}
