#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"
#include "spaceObjects/warpJammer.h"
#include "components/reactor.h"
#include "components/shipsystem.h"
#include "main.h"

GuiPowerDamageIndicator::GuiPowerDamageIndicator(GuiContainer* owner, string name, ShipSystem::Type system, sp::Alignment icon_align)
: GuiElement(owner, name), system(system), text_size(30), icon_align(icon_align)
{
}

void GuiPowerDamageIndicator::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship)
        return;
    auto reactor = my_spaceship.getComponent<Reactor>();
    auto sys = ShipSystem::get(my_spaceship, system);
    if (!sys)
        return;

    glm::u8vec4 color;
    string display_text;

    float power = sys->power_level;
    float health = sys->health;
    float heat = sys->heat_level;
    float hacked_level = sys->hacked_level;
    if (system == ShipSystem::Type::FrontShield)
    {
        auto rear = ShipSystem::get(my_spaceship, ShipSystem::Type::RearShield);
        if (rear) {
            power = std::max(power, rear->power_level);
            health = std::max(health, rear->health);
            heat = std::max(heat, rear->heat_level);
            hacked_level = std::max(hacked_level, rear->hacked_level);
        }
    }
    if (health <= 0.0f)
    {
        color = colorConfig.overlay_damaged;
        display_text = tr("systems", "DAMAGED");
    }else if ((system == ShipSystem::Type::Warp || system == ShipSystem::Type::JumpDrive) && WarpJammer::isWarpJammed(my_spaceship))
    {
        color = colorConfig.overlay_jammed;
        display_text = tr("systems", "JAMMED");
    }else if (power == 0.0f)
    {
        color = colorConfig.overlay_no_power;
        display_text = tr("systems", "NO POWER");
    }else if (reactor && reactor->energy < 10.0f)
    {
        color = colorConfig.overlay_low_energy;
        display_text = tr("systems", "LOW ENERGY");
    }else if (power < 0.3f)
    {
        color = colorConfig.overlay_low_power;
        display_text = tr("systems", "LOW POWER");
    }else if (heat > 0.90f)
    {
        color = colorConfig.overlay_overheating;
        display_text = tr("systems", "OVERHEATING");
    }else if (hacked_level > 0.1f)
    {
        color = colorConfig.overlay_hacked;
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
    {
        drawIcon(renderer, "gui/icons/status_damaged", colorConfig.overlay_damaged);
    }
    if ((system == ShipSystem::Type::Warp || system == ShipSystem::Type::JumpDrive) && WarpJammer::isWarpJammed(my_spaceship))
    {
        drawIcon(renderer, "gui/icons/status_jammed", colorConfig.overlay_jammed);
    }
    if (power == 0.0f)
    {
        drawIcon(renderer, "gui/icons/status_no_power", colorConfig.overlay_no_power);
    }
    else if (power < 0.3f)
    {
        drawIcon(renderer, "gui/icons/status_low_power", colorConfig.overlay_low_power);
    }
    if (reactor && reactor->energy < 10.0f)
    {
        drawIcon(renderer, "gui/icons/status_low_energy", colorConfig.overlay_low_energy);
    }
    if (heat > 0.90f)
    {
        drawIcon(renderer, "gui/icons/status_overheat", colorConfig.overlay_overheating);
    }
}

void GuiPowerDamageIndicator::drawIcon(sp::RenderTarget& renderer, string icon_name, glm::u8vec4 color)
{
    renderer.drawSprite(icon_name, icon_position, icon_size);
    icon_position += icon_offset;
}
