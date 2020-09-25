#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "powerDamageIndicator.h"
#include "spaceObjects/warpJammer.h"

GuiPowerDamageIndicator::GuiPowerDamageIndicator(GuiContainer* owner, string name, ESystem system, EGuiAlign icon_align)
: GuiElement(owner, name), system(system), text_size(30), icon_align(icon_align)
{
}

void GuiPowerDamageIndicator::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;

    sf::Color color;
    string display_text;

    float power = my_spaceship->systems[system].power_level;
    float health = my_spaceship->systems[system].health;
    float heat = my_spaceship->systems[system].heat_level;
    float hacked_level = my_spaceship->systems[system].hacked_level;
    if (system == SYS_FrontShield)
    {
        power = std::max(power, my_spaceship->systems[SYS_RearShield].power_level);
        health = std::max(health, my_spaceship->systems[SYS_RearShield].health);
        heat = std::max(heat, my_spaceship->systems[SYS_RearShield].heat_level);
        hacked_level = std::max(hacked_level, my_spaceship->systems[SYS_RearShield].hacked_level);
    }
    if (health <= 0.0)
    {
        color = colorConfig.overlay_damaged;
        display_text = "DAMAGED";
    }else if ((system == SYS_Warp || system == SYS_JumpDrive) && WarpJammer::isWarpJammed(my_spaceship->getPosition()))
    {
        color = colorConfig.overlay_jammed;
        display_text = "JAMMED";
    }else if (power == 0.0)
    {
        color = colorConfig.overlay_no_power;
        display_text = "NO POWER";
    }else if (my_spaceship->energy_level < 10)
    {
        color = colorConfig.overlay_low_energy;
        display_text = "LOW ENERGY";
    }else if (power < 0.3)
    {
        color = colorConfig.overlay_low_power;
        display_text = "LOW POWER";
    }else if (heat > 0.90)
    {
        color = colorConfig.overlay_overheating;
        display_text = "OVERHEATING";
    }else if (hacked_level > 0.1)
    {
        color = colorConfig.overlay_hacked;
        display_text = "HACKED";
    }else{
        return;
    }
    drawStretched(window, rect, "gui/damage_power_overlay", color);

    if (rect.height > rect.width)
        drawVerticalText(window, rect, display_text, ACenter, text_size, bold_font, color);
    else
        drawText(window, rect, display_text, ACenter, text_size, bold_font, color);

    icon_size = std::min(rect.width, rect.height) * 0.8;
    switch(icon_align)
    {
    case ACenterLeft:
        icon_position = sf::Vector2f(rect.left - icon_size / 2.0, rect.top + rect.height / 2.0);
        icon_offset = sf::Vector2f(-icon_size, 0);
        break;
    case ACenterRight:
        icon_position = sf::Vector2f(rect.left + rect.width + icon_size / 2.0, rect.top + rect.height / 2.0);
        icon_offset = sf::Vector2f(icon_size, 0);
        break;
    case ABottomRight:
        icon_position = sf::Vector2f(rect.left + rect.width + icon_size / 2.0, rect.top + rect.height - icon_size / 2.0);
        icon_offset = sf::Vector2f(0, -icon_size);
        break;
    case ABottomLeft:
        icon_position = sf::Vector2f(rect.left - icon_size / 2.0, rect.top + rect.height - icon_size / 2.0);
        icon_offset = sf::Vector2f(0, -icon_size);
        break;
    case ATopRight:
        icon_position = sf::Vector2f(rect.left + rect.width + icon_size / 2.0, rect.top + icon_size / 2.0);
        icon_offset = sf::Vector2f(0, icon_size);
        break;
    case ATopLeft:
        icon_position = sf::Vector2f(rect.left - icon_size / 2.0, rect.top + icon_size / 2.0);
        icon_offset = sf::Vector2f(0, icon_size);
        break;
    case ATopCenter:
        icon_position = sf::Vector2f(rect.left + rect.width / 2.0, rect.top - icon_size / 2.0);
        icon_offset = sf::Vector2f(0, -icon_size);
        break;
    case ABottomCenter:
        icon_position = sf::Vector2f(rect.left + rect.width / 2.0, rect.top + rect.height + icon_size / 2.0);
        icon_offset = sf::Vector2f(0, icon_size);
        break;
    case ACenter:
        icon_position = sf::Vector2f(rect.left + rect.width / 2.0, rect.top + rect.height / 2.0);
        icon_offset = sf::Vector2f(0, 0);
        break;
    }

    if (health <= 0.0)
    {
        drawIcon(window, "gui/icons/status_damaged", colorConfig.overlay_damaged);
    }
    if ((system == SYS_Warp || system == SYS_JumpDrive) && WarpJammer::isWarpJammed(my_spaceship->getPosition()))
    {
        drawIcon(window, "gui/icons/status_jammed", colorConfig.overlay_jammed);
    }
    if (power == 0.0)
    {
        drawIcon(window, "gui/icons/status_no_power", colorConfig.overlay_no_power);
    }
    else if (power < 0.3)
    {
        drawIcon(window, "gui/icons/status_low_power", colorConfig.overlay_low_power);
    }
    if (my_spaceship->energy_level < 10)
    {
        drawIcon(window, "gui/icons/status_low_energy", colorConfig.overlay_low_energy);
    }
    if (heat > 0.90)
    {
        drawIcon(window, "gui/icons/status_overheat", colorConfig.overlay_overheating);
    }
}

void GuiPowerDamageIndicator::drawIcon(sf::RenderTarget& window, string icon_name, sf::Color color)
{
    sf::Sprite icon;
    textureManager.setTexture(icon, icon_name);
    float scale = icon_size / icon.getTextureRect().height;
    icon.setScale(scale, scale);
    icon.setPosition(icon_position);
    icon.setColor(color);
    window.draw(icon);

    icon_position += icon_offset;
}
