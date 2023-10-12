#include "gui2_scrollbar.h"
#include "gui2_arrowbutton.h"
#include "theme.h"


GuiScrollbar::GuiScrollbar(GuiContainer* owner, string id, int min_value, int max_value, int start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), desired_value(start_value), value_size(1), func(func)
{
    back_style = theme->getStyle("scrollbar.back");
    front_style = theme->getStyle("scrollbar.front");

    (new GuiArrowButton(this, id + "_UP_ARROW", 90, [this]() {
        setValue(getValue() - click_change);
    }))->setPosition(0, 0, sp::Alignment::TopRight)->setSize(GuiSizeMax, GuiSizeMatchWidth);
    (new GuiArrowButton(this, id + "_DOWN_ARROW", -90, [this]() {
        setValue(getValue() + click_change);
    }))->setPosition(0, 0, sp::Alignment::BottomRight)->setSize(GuiSizeMax, GuiSizeMatchWidth);
}

void GuiScrollbar::onDraw(sp::RenderTarget& renderer)
{
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    renderer.drawStretched(rect, back.texture, back.color);

    // Update the bar's range, size, and draggable bar size.
    range = max_value - min_value - value_size;
    arrow_size = rect.size.x / 2.0f;
    move_height = rect.size.y - arrow_size * 2;
    // Clamp the size of the draggable bar to no less than 20px.
    bar_size = std::clamp(move_height * value_size / (range + value_size), 20.0F, move_height);
    // Set the bottom of the draggable bar no lower than the top of the bottom arrow.
    const float bar_y = std::min((rect.position.y + arrow_size + (move_height - bar_size) * getValue() / range), rect.position.y + rect.size.y - arrow_size - bar_size);

    renderer.drawStretched(sp::Rect(rect.position.x, bar_y, rect.size.x, bar_size), front.texture, front.color);
}

bool GuiScrollbar::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    float bar_y = rect.position.y + arrow_size + (move_height - bar_size) * getValue() / range;
    if (position.y >= bar_y && position.y <= bar_y + bar_size)
    {
        drag_scrollbar = true;
        drag_select_offset = position.y - bar_y;
    }else{
        drag_scrollbar = false;
    }
    return true;
}

void GuiScrollbar::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (drag_scrollbar)
    {
        float target_y_offset = position.y - drag_select_offset - (rect.position.y + arrow_size);
        target_y_offset = std::max(target_y_offset, 0.0f);
        target_y_offset = std::min(target_y_offset, move_height - bar_size);

        if (bar_size < move_height)
            setValue(int(target_y_offset / (move_height - bar_size) * range + 0.5f));
    }
}

void GuiScrollbar::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (!drag_scrollbar)
    {
        float target_y_offset = position.y - bar_size / 2.0f - (rect.position.y + arrow_size);
        target_y_offset = std::max(target_y_offset, 0.0f);
        target_y_offset = std::min(target_y_offset, move_height - bar_size);

        if (bar_size < move_height)
            setValue(int(target_y_offset / (move_height - bar_size) * range + 0.5f));
    }
}

void GuiScrollbar::setRange(int min_value, int max_value)
{
    this->min_value = min_value;
    this->max_value = max_value;
}

void GuiScrollbar::setValueSize(int size)
{
    value_size = size;
}

void GuiScrollbar::setClickChange(int change)
{
    click_change = change;
}

void GuiScrollbar::setValue(int value)
{
    if (this->desired_value == value)
        return;

    this->desired_value = value;

    if (func)
        func(getValue());
}

int GuiScrollbar::getValue() const
{
    auto value = desired_value;
    if (value > max_value - value_size)
        value = max_value - value_size;
    if (value < min_value)
        value = min_value;

    return value;
}

int GuiScrollbar::getMax() const
{
    return max_value;
}

int GuiScrollbar::getMin() const
{
    return min_value;
}
