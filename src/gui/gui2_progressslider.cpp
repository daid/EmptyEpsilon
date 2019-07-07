#include "gui2_progressslider.h"

GuiProgressSlider::GuiProgressSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func), color(sf::Color(255, 255, 255, 64)), drawBackground(true)

{
}

void GuiProgressSlider::onDraw(sf::RenderTarget& window)
{
    float f = (value - min_value) / (max_value - min_value);

    if (drawBackground)
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
    drawText(window, rect, text, ACenter);
}

GuiProgressSlider* GuiProgressSlider::setText(string text)
{
    this->text = text;
    return this;
}

GuiProgressSlider* GuiProgressSlider::setColor(sf::Color color)
{
    this->color = color;
    return this;
}

GuiProgressSlider* GuiProgressSlider::setDrawBackground(bool drawBackground)
{
    this->drawBackground = drawBackground;
    return this;
}

bool GuiProgressSlider::onMouseDown(sf::Vector2f position)
{
    onMouseDrag(position);
    return true;
}

void GuiProgressSlider::onMouseDrag(sf::Vector2f position)
{
    float new_value;
    if (rect.width > rect.height)
        new_value = (position.x - rect.left+2) / (rect.width-4);
    else
        new_value = (position.y - rect.top+2) / (rect.height-4);
    new_value = min_value + (max_value - min_value) * new_value;
    if (min_value < max_value)
    {
        if (new_value < min_value)
            new_value = min_value;
        if (new_value > max_value)
            new_value = max_value;
    }else{
        if (new_value > min_value)
            new_value = min_value;
        if (new_value < max_value)
            new_value = max_value;
    }
    if (value != new_value)
    {
        value = new_value;
        if (func)
        {
            func_t f = func;
            f(value);
        }
    }
}

void GuiProgressSlider::onMouseUp(sf::Vector2f position)
{
}

GuiProgressSlider* GuiProgressSlider::setValue(float value)
{
    if (min_value < max_value)
    {
        if (value < min_value)
            value = min_value;
        if (value > max_value)
            value = max_value;
    }else{
        if (value > min_value)
            value = min_value;
        if (value < max_value)
            value = max_value;
    }
    this->value = value;
    return this;
}

GuiProgressSlider* GuiProgressSlider::setRange(float min, float max)
{
    this->min_value = min;
    this->max_value = max;
    setValue(this->value);
    return this;
}


float GuiProgressSlider::getValue() const
{
    return value;
}
