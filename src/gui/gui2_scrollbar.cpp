#include "gui2_scrollbar.h"
#include "gui2_arrowbutton.h"

GuiScrollbar::GuiScrollbar(GuiContainer* owner, string id, int min_value, int max_value, int start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), value_size(1), func(func)
{
    (new GuiArrowButton(this, id + "_UP_ARROW", 90, [this]() {
        setValue(getValue() - 1);
    }))->setPosition(0, 0, ATopRight)->setSize(GuiSizeMax, GuiSizeMatchWidth);
    (new GuiArrowButton(this, id + "_DOWN_ARROW", -90, [this]() {
        setValue(getValue() + 1);
    }))->setPosition(0, 0, ABottomRight)->setSize(GuiSizeMax, GuiSizeMatchWidth);
}

void GuiScrollbar::onDraw(sf::RenderTarget& window)
{
    drawStretched(window, rect, "gui/ScrollbarBackground");
    
    int range = (max_value - min_value);
    float arrow_size = rect.width / 2.0;
    float move_height = (rect.height - arrow_size * 2);
    float bar_size = move_height * value_size / range;
    if (bar_size > move_height)
        bar_size = move_height;
    drawStretched(window, sf::FloatRect(rect.left, rect.top + arrow_size + move_height * value / range, rect.width, bar_size), "gui/ScrollbarSelection", sf::Color::White);
}

bool GuiScrollbar::onMouseDown(sf::Vector2f position)
{
    int range = (max_value - min_value);
    float arrow_size = rect.width / 2.0;
    float move_height = (rect.height - arrow_size * 2);
    float bar_size = move_height * value_size / range;
    if (bar_size > move_height)
        bar_size = move_height;
    float bar_y = rect.top + arrow_size + move_height * value / range;
    if (position.y >= bar_y && position.y <= bar_y + bar_size)
    {
        drag_scrollbar = true;
        drag_select_offset = position.y - bar_y;
    }else{
        drag_scrollbar = false;
    }
    return true;
}

void GuiScrollbar::onMouseDrag(sf::Vector2f position)
{
    if (drag_scrollbar)
    {
        float arrow_size = rect.width / 2.0;
        int range = (max_value - min_value);
        float move_height = (rect.height - arrow_size * 2);
        float bar_size = move_height * value_size / range;
        if (bar_size > move_height)
            bar_size = move_height;
        
        float target_y_offset = position.y - drag_select_offset - (rect.top + arrow_size);
        target_y_offset = std::max(target_y_offset, 0.0f);
        target_y_offset = std::min(target_y_offset, move_height - bar_size);
        
        if (bar_size < move_height)
            setValue(int(target_y_offset / move_height * range + 0.5f));
    }
}

void GuiScrollbar::onMouseUp(sf::Vector2f position)
{
    if (!drag_scrollbar)
    {
        float arrow_size = rect.width / 2.0;
        int range = (max_value - min_value);
        float move_height = (rect.height - arrow_size * 2);
        float bar_size = move_height * value_size / range;
        if (bar_size > move_height)
            bar_size = move_height;
        
        float target_y_offset = position.y - bar_size / 2.0f - (rect.top + arrow_size);
        target_y_offset = std::max(target_y_offset, 0.0f);
        target_y_offset = std::min(target_y_offset, move_height - bar_size);
        
        if (bar_size < move_height)
            setValue(int(target_y_offset / move_height * range + 0.5f));
    }
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

int GuiScrollbar::getMax()
{
    return max_value;
}

int GuiScrollbar::getMin()
{
    return min_value;
}
