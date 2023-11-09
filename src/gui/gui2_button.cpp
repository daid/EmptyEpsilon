#include "soundManager.h"
#include "theme.h"
#include "gui2_button.h"
#include "preferenceManager.h"

GuiButton::GuiButton(GuiContainer* owner, string id, string text, func_t func)
: GuiElement(owner, id), text(text), func(func)
{
    text_size = -1;
    back_style = theme->getStyle("button.back");
    front_style = theme->getStyle("button.front");
}

void GuiButton::onDraw(sp::RenderTarget& renderer)
{
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());
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
        renderer.drawRotatedSprite(icon_name, glm::vec2(icon_x, rect.position.y + rect.size.y * 0.5f), rect.size.y * 0.8f, icon_rotation, front.color);
        renderer.drawText(text_rect, text, text_align, text_size > 0 ? text_size : front.size, front.font, front.color);
    }else{
        renderer.drawText(rect, text, sp::Alignment::Center, text_size > 0 ? text_size : front.size, front.font, front.color);
    }
}

bool GuiButton::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}

void GuiButton::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (rect.contains(position))
    {
        soundManager->playSound("sfx/button.wav");
        if (func)
        {
            func_t f = func;
            f();
        }
    }
}

string GuiButton::getText() const
{
    return text;
}

GuiButton* GuiButton::setText(string text)
{
    this->text = text;
    return this;
}

GuiButton* GuiButton::setTextSize(float size)
{
    text_size = size;
    return this;
}

GuiButton* GuiButton::setIcon(string icon_name, sp::Alignment icon_alignment, float rotation)
{
    this->icon_name = icon_name;
    this->icon_alignment = icon_alignment;
    this->icon_rotation = rotation;
    return this;
}

GuiButton* GuiButton::setStyle(const string& style)
{
    back_style = theme->getStyle(style + ".back");
    front_style = theme->getStyle(style + ".front");
    return this;
}

string GuiButton::getIcon() const
{
    return icon_name;
}
