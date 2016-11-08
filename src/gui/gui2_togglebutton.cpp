#include "gui2_togglebutton.h"

GuiToggleButton::GuiToggleButton(GuiContainer* owner, string id, string text, func_t func)
: GuiButton(owner, id, text, [this]() { this->onClick(); }), toggle_func(func)
{
    value = false;
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
    setActive(value);
    return this;
}

void GuiToggleButton::onClick()
{
    setValue(!value);
    if (toggle_func)
    {
        func_t f = toggle_func;
        f(value);
    }
}
