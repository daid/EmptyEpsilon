#include "gui2_scrollbar.h"
#include "gui2_arrowbutton.h"

GuiScrollbar::GuiScrollbar(GuiContainer* owner, string id, int min_value, int max_value, int start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), value_size(1), func(func)
{
    (new GuiArrowButton(this, id + "_UP_ARROW", 90, [this](GuiButton*) {
        setValue(getValue() - 1);
    }))->setPosition(0, 0, ATopRight)->setSize(GuiSizeMax, GuiSizeMatchWidth);
    (new GuiArrowButton(this, id + "_DOWN_ARROW", -90, [this](GuiButton*) {
        setValue(getValue() + 1);
    }))->setPosition(0, 0, ABottomRight)->setSize(GuiSizeMax, GuiSizeMatchWidth);
}

void GuiScrollbar::onDraw(sf::RenderTarget& window)
{
    draw9Cut(window, rect, "border_background", sf::Color::White);
    
    int range = (max_value - min_value);
    float move_height = (rect.height - rect.width * 2);
    float bar_size = move_height * value_size / range;
    if (bar_size > move_height)
        bar_size = move_height;
    draw9Cut(window, sf::FloatRect(rect.left, rect.top + rect.width + move_height * value / range, rect.width, bar_size), "button_background", sf::Color::White);
}

bool GuiScrollbar::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiScrollbar::onMouseDrag(sf::Vector2f position)
{
}

void GuiScrollbar::onMouseUp(sf::Vector2f position)
{
}

void GuiScrollbar::setRange(int min_value, int max_value)
{
    this->min_value = min_value;
    this->max_value = max_value;
    setValue(value);
}

void GuiScrollbar::setValueSize(int size)
{
    value_size = size;
    setValue(value);
}

void GuiScrollbar::setValue(int value)
{
    if (value > max_value - value_size)
        value = max_value - value_size;
    if (value < min_value)
        value = min_value;
    if (this->value == value)
        return;
    
    this->value = value;
    if (func)
        func(value);
}

int GuiScrollbar::getValue()
{
    return value;
}
