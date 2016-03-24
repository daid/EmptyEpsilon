#include "gui2_arrow.h"

GuiArrow::GuiArrow(GuiContainer* owner, string id, float angle)
: GuiElement(owner, id), color(sf::Color::White), angle(angle)
{
}

void GuiArrow::onDraw(sf::RenderTarget& window)
{
    drawArrow(window, rect, color, angle);
}
