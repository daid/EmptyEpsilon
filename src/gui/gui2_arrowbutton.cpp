#include "gui2_arrowbutton.h"

GuiArrowButton::GuiArrowButton(GuiContainer* owner, string id, float angle, func_t func)
: GuiButton(owner, id, "", func), angle(angle)
{
}

void GuiArrowButton::onDraw(sf::RenderTarget& window)
{
    sf::Color color = selectColor(colorConfig.button.forground);
    drawArrow(window, rect, color, angle);
}
