#include "soundManager.h"
#include "colorConfig.h"
#include "gui2_button.h"
#include "preferenceManager.h"

GuiButton::GuiButton(GuiContainer* owner, string id, string text, func_t func)
: GuiElement(owner, id), text(text), func(func)
{
    text_size = 30;
    color_set = colorConfig.button;
}

void GuiButton::onDraw(sp::RenderTarget& renderer)
{
    glm::u8vec4 color = selectColor(color_set.background);
    glm::u8vec4 text_color = selectColor(color_set.forground);

    if (!enabled)
        renderer.drawStretched(rect, "gui/widget/ButtonBackground.disabled.png", color);
    else if (active)
        renderer.drawStretched(rect, "gui/widget/ButtonBackground.active.png", color);
    else if (hover)
        renderer.drawStretched(rect, "gui/widget/ButtonBackground.hover.png", color);
    else
        renderer.drawStretched(rect, "gui/widget/ButtonBackground.png", color);

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
            icon_x = rect.position.x + rect.size.y * 0.5;
            text_rect.position.x = rect.position.x + rect.size.y;
            break;
        default:
            icon_x = rect.position.x + rect.size.x - rect.size.y * 0.5;
            text_rect.size.x = rect.size.x - rect.size.y;
            text_align = sp::Alignment::CenterRight;
        }
        renderer.drawSprite(icon_name, glm::vec2(icon_x, rect.position.y + rect.size.y * 0.5), rect.size.y * 0.8, text_color);
        renderer.drawText(text_rect, text, text_align, text_size, main_font, text_color);
    }else{
        renderer.drawText(rect, text, sp::Alignment::Center, text_size, main_font, text_color);
    }
}

bool GuiButton::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, int id)
{
    return true;
}

void GuiButton::onMouseUp(glm::vec2 position, int id)
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

GuiButton* GuiButton::setColors(WidgetColorSet color_set)
{
    this->color_set = color_set;
    return this;
}

string GuiButton::getIcon() const
{
    return icon_name;
}

WidgetColorSet GuiButton::getColors() const
{
    return color_set;
}
