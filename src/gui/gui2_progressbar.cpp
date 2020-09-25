#include "gui2_progressbar.h"

GuiProgressbar::GuiProgressbar(GuiContainer* owner, string id, float min_value, float max_value, float start_value)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), color(sf::Color(255, 255, 255, 64)), drawBackground(true)
{
}

void GuiProgressbar::onDraw(sf::RenderTarget& window)
{
    float f = (value - min_value) / (max_value - min_value);

    if (drawBackground)
        drawStretched(window, rect, "gui/ProgressbarBackground");

    sf::FloatRect fill_rect = rect;
    if (rect.width >= rect.height)
    {
        fill_rect.width *= f;
        if (max_value < min_value)
            fill_rect.left = rect.left + rect.width - fill_rect.width;
        drawStretchedH(window, fill_rect, "gui/ProgressbarFill", color);
    }
    else
    {
        fill_rect.height *= f;
        fill_rect.top = rect.top + rect.height - fill_rect.height;
        drawStretchedV(window, fill_rect, "gui/ProgressbarFill", color);
    }
    drawText(window, rect, text, ACenter);
}

GuiProgressbar* GuiProgressbar::setValue(float value)
{
    this->value = value;
    return this;
}

GuiProgressbar* GuiProgressbar::setRange(float min_value, float max_value)
{
    this->min_value = min_value;
    this->max_value = max_value;
    return this;
}

GuiProgressbar* GuiProgressbar::setText(string text)
{
    this->text = text;
    return this;
}

GuiProgressbar* GuiProgressbar::setColor(sf::Color color)
{
    this->color = color;
    return this;
}

GuiProgressbar* GuiProgressbar::setDrawBackground(bool drawBackground)
{
    this->drawBackground = drawBackground;
    return this;
}
