#include "gui2_progressbar.h"

GuiProgressbar::GuiProgressbar(GuiContainer* owner, string id, float min, float max, float value)
: GuiElement(owner, id), min(min), max(max), value(value), color(sf::Color::White), border_color(sf::Color::White)
{
}

void GuiProgressbar::onDraw(sf::RenderTarget& window)
{
    float f = (value - min) / (max - min);

    drawStretched(window, rect, "gui/ProgressbarBackground");

    sf::FloatRect fill_rect = rect;
    if (rect.width >= rect.height)
    {
        fill_rect.width *= f;
        drawStretchedH(window, fill_rect, "gui/ProgressbarFill", color);
    }
    else
    {
        fill_rect.height *= f;
        fill_rect.top = rect.top + rect.height - fill_rect.height;
        drawStretchedV(window, fill_rect, "gui/ProgressbarFill", color);
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
