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
    if (icon_name != "")
    {
        sp::Rect text_rect = rect;
        sp::Alignment text_align = sp::Alignment::CenterLeft;
        float icon_x;
        switch(icon_alignment)
        {
        case sp::Alignment::CenterLeft:
        case sp::Alignment::TopLeft:
        case sp::Alignment::BottomLeft:
            icon_x = rect.position.x + rect.size.y * 0.5f;
            text_rect.position.x = rect.position.x + rect.size.y;
            break;
        default:
            icon_x = rect.position.x + rect.size.x - rect.size.y * 0.5f;
            text_rect.size.x = rect.size.x - rect.size.y;
            text_align = sp::Alignment::CenterRight;
        }
        renderer.drawSprite(icon_name, glm::vec2(icon_x, rect.position.y + rect.size.y * 0.5f), rect.size.y * 0.8f, front.color);
        renderer.drawText(text_rect, text, text_align, text_size > 0 ? text_size : front.size, front.font, front.color);
    }else{
        renderer.drawText(rect, text, sp::Alignment::Center, text_size > 0 ? text_size : front.size, front.font, front.color);
    }
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
