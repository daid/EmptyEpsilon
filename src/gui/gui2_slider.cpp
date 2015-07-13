#include <math.h>

#include "gui2_slider.h"

GuiSlider::GuiSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), snap_value(std::numeric_limits<float>::infinity()), func(func)
{
}

void GuiSlider::onDraw(sf::RenderTarget& window)
{
    draw9Cut(window, rect, "button_background", sf::Color(64,64,64, 255));

    sf::Color color = sf::Color::White;
    if (!enabled)
        color = color * sf::Color(96, 96, 96, 255);
    else if (hover)
        color = sf::Color(255,255,255, 128);
    if (rect.width > rect.height)
    {
        float x;
    
        if (snap_value != std::numeric_limits<float>::infinity())
        {
            x = rect.left + (rect.width - rect.height) * (snap_value - min_value) / (max_value - min_value);
            sf::RectangleShape backgroundZero(sf::Vector2f(8.0, rect.height));
            backgroundZero.setPosition(x + rect.height / 2.0 - 4.0, rect.top);
            backgroundZero.setFillColor(sf::Color(8,8,8,255));
            window.draw(backgroundZero);
        }
        x = rect.left + (rect.width - rect.height) * (value - min_value) / (max_value - min_value);
        draw9Cut(window, sf::FloatRect(x, rect.top, rect.height, rect.height), "button_background", color);
    }else{
        float y;
        if (snap_value != std::numeric_limits<float>::infinity())
        {
            y = rect.top + (rect.height - rect.width) * (snap_value - min_value) / (max_value - min_value);
            sf::RectangleShape backgroundZero(sf::Vector2f(rect.width, 8.0));
            backgroundZero.setPosition(rect.left, y + rect.width / 2.0 - 4.0);
            backgroundZero.setFillColor(sf::Color(8,8,8,255));
            window.draw(backgroundZero);
        }
        y = rect.top + (rect.height - rect.width) * (value - min_value) / (max_value - min_value);
        draw9Cut(window, sf::FloatRect(rect.left, y, rect.width, rect.width), "button_background", color);
    }
}

bool GuiSlider::onMouseDown(sf::Vector2f position)
{
    onMouseDrag(position);
    return true;
}

void GuiSlider::onMouseDrag(sf::Vector2f position)
{
    float new_value;
    if (rect.width > rect.height)
        new_value = (position.x - rect.left - (rect.height / 2.0)) / (rect.width - rect.height);
    else
        new_value = (position.y - rect.top - (rect.width / 2.0)) / (rect.height - rect.width);
    new_value = min_value + (max_value - min_value) * new_value;
    if (fabs(new_value - snap_value) < snap_range)
        new_value = snap_value;
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
            func(value);
    }
}

void GuiSlider::onMouseUp(sf::Vector2f position)
{
}

GuiSlider* GuiSlider::setSnapValue(float value, float range)
{
    snap_value = value;
    snap_range = range;
    return this;
}

GuiSlider* GuiSlider::setValue(float value)
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

float GuiSlider::getValue()
{
    return value;
}
