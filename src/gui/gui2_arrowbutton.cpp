#include "gui2_arrowbutton.h"

GuiArrowButton::GuiArrowButton(GuiContainer* owner, string id, float angle, func_t func)
: GuiButton(owner, id, "", func), angle(angle)
{
}

void GuiArrowButton::onDraw(sf::RenderTarget& window)
{
    sf::Color color = button_color;
    if (!enabled)
        color = color * sf::Color(96, 96, 96, 255);
    else if (has_focus)
        color = color * sf::Color(128, 128, 128, 255);
    drawArrow(window, rect, color, angle);
}
