#include "gui2_togglebutton.h"

GuiToggleButton::GuiToggleButton(GuiContainer* owner, string id, string text, func_t func)
: GuiButton(owner, id, text, [this]() { this->onClick(); }), toggle_func(func)
{
    selected_color = sf::Color::White;
    unselected_color = sf::Color(192, 192, 192, 255);
    value = false;
    setColor(unselected_color);
}

bool GuiToggleButton::getValue()
{
    return value;
}

GuiToggleButton* GuiToggleButton::setValue(bool value)
{
    if (this->value == value)
        return this;
    this->value = value;
    if (value)
        setColor(selected_color);
    else
        setColor(unselected_color);
    return this;
}

void GuiToggleButton::onClick()
{
    setValue(!value);
    if (toggle_func)
        toggle_func(value);
}
