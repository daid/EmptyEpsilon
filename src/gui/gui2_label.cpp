#include "gui2_label.h"
#include "theme.h"


GuiLabel::GuiLabel(GuiContainer* owner, string id, string text, float text_size)
: GuiElement(owner, id), text(text), text_size(text_size), text_color(glm::u8vec4{255,255,255,255}), text_alignment(sp::Alignment::Center), background(false), bold(false), vertical(false)
{
    front_style = theme->getStyle("label.front");
    back_style = theme->getStyle("label.back");
}

void GuiLabel::onDraw(sp::RenderTarget& renderer)
{
    auto back = back_style->get(getState());
    auto front = front_style->get(getState());
    
    if (background)
        renderer.drawStretched(rect, back.texture, back.color);
    if (vertical)
        renderer.drawText(rect, text, text_alignment, text_size, front.font, front.color, sp::Font::FlagVertical);
    else
        renderer.drawText(rect, text, text_alignment, text_size, front.font, front.color);
}

GuiLabel* GuiLabel::setText(string text)
{
    this->text = text;
    return this;
}

string GuiLabel::getText() const
{
    return text;
}

GuiLabel* GuiLabel::setAlignment(sp::Alignment alignment)
{
    text_alignment = alignment;
    return this;
}

GuiLabel* GuiLabel::addBackground()
{
    background = true;
    return this;
}

GuiLabel* GuiLabel::setVertical()
{
    vertical = true;
    return this;
}
