#include "gui2_box.h"

GuiBox::GuiBox(GuiContainer* owner, string id)
: GuiElement(owner, id), fill_color(0, 0, 0, 0)
{
}

void GuiBox::onDraw(sf::RenderTarget& window)
{
    if (fill_color.a > 0)
        draw9Cut(window, rect, "button_background", fill_color);
    draw9Cut(window, rect, "border_background", sf::Color::White);
}

GuiBox* GuiBox::fill(sf::Color color)
{
    fill_color = color;
    return this;
}
