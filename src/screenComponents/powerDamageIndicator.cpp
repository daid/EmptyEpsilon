#include <libintl.h>

#include "playerInfo.h"
#include "powerDamageIndicator.h"
#include "spaceObjects/warpJammer.h"

GuiPowerDamageIndicator::GuiPowerDamageIndicator(GuiContainer* owner, string name, ESystem system)
: GuiElement(owner, name), system(system), text_size(20)
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
    int alpha = 128;
    if (system == SYS_FrontShield)
    {
        power = std::max(power, my_spaceship->systems[SYS_RearShield].power_level);
        health = std::max(health, my_spaceship->systems[SYS_RearShield].health);
        heat = std::max(heat, my_spaceship->systems[SYS_RearShield].heat_level);
    }
    if (health <= 0.0)
    {
        color = sf::Color::Red;
        display_text = gettext("DAMAGED");
    }else if ((system == SYS_Warp || system == SYS_JumpDrive) && WarpJammer::isWarpJammed(my_spaceship->getPosition()))
    {
        color = sf::Color::Red;
        display_text = gettext("JAMMED");
    }else if (power == 0.0)
    {
        color = sf::Color::Red;
        display_text = gettext("NO POWER");
    }else if (my_spaceship->energy_level < 10)
    {
        color = sf::Color(255, 128, 0);
        alpha = 64;
        display_text = gettext("LOW ENERGY");
    }else if (power < 0.3)
    {
        color = sf::Color(255, 128, 0);
        alpha = 64;
        display_text = gettext("LOW POWER");
    }else if (heat > 0.90)
    {
        color = sf::Color(255, 128, 0);
        alpha = 64;
        display_text = gettext("OVERHEATING");
    }else{
        return;
    }
    draw9Cut(window, rect, "button_background", sf::Color(0, 0, 0, alpha));
    draw9Cut(window, rect, "border_background", color);

    if (rect.height > rect.width)
        drawVerticalText(window, rect, display_text, ACenter, text_size, color);
    else
        drawText(window, rect, display_text, ACenter, text_size, color);
}
