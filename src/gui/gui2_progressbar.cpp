#include "gui2_progressbar.h"

GuiProgressbar::GuiProgressbar(GuiContainer* owner, string id, float min, float max, float value)
: GuiElement(owner, id), min(min), max(max), value(value), color(sf::Color::White), border_color(sf::Color::White)
{
}

void GuiProgressbar::onDraw(sf::RenderTarget& window)
{
    float f = (value - min) / (max - min);

    if (color != border_color)
    {
        if (rect.width >= rect.height)
            draw9Cut(window, rect, "button_background", color, f);
        else
            draw9CutV(window, rect, "button_background", color, f);
    }
    draw9Cut(window, rect, "border_background", border_color);
    if (color == border_color)
    {
        if (rect.width >= rect.height)
            draw9Cut(window, rect, "button_background", color, f);
        else
            draw9CutV(window, rect, "button_background", color, f);
    }
}

GuiProgressbar* GuiProgressbar::setValue(float value)
{
    this->value = value;
    return this;
}

GuiProgressbar* GuiProgressbar::setColor(sf::Color color)
{
    this->color = color;
    return this;
}
