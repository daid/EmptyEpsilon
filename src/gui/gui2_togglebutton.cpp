#include "gui2_togglebutton.h"
#include "theme.h"


GuiToggleButton::GuiToggleButton(GuiContainer* owner, string id, string text, func_t func)
: GuiButton(owner, id, text, [this]() { this->onClick(); }), toggle_func(func)
{
    value = false;
    setStyle("button.toggle.off");
    back_on_style = theme->getStyle("button.toggle.on.back");
    front_on_style = theme->getStyle("button.toggle.on.front");
}

void GuiToggleButton::onDraw(sp::RenderTarget& renderer)
{
    const auto& back = value ? back_on_style->get(getState()) : back_style->get(getState());
    const auto& front = value ? front_on_style->get(getState()) : front_style->get(getState());
    renderer.drawStretched(rect, back.texture, back.color);
    renderer.drawText(rect, text, sp::Alignment::Center, text_size > 0 ? text_size : front.size, front.font, front.color);
}

bool GuiToggleButton::getValue() const
{
    return value;
}

GuiToggleButton* GuiToggleButton::setValue(bool value)
{
    if (this->value == value)
        return this;
    this->value = value;
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
