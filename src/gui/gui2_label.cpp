#include "gui2_label.h"
#include "theme.h"

GuiLabel::GuiLabel(GuiContainer* owner, string id, string text, float text_size)
: GuiElement(owner, id), text(text), text_size(text_size), text_color(glm::u8vec4{255,255,255,255}), text_alignment(sp::Alignment::Center), background(false), font_flag(sp::Font::FlagLineWrap)
{
    front_style = theme->getStyle("label.front");
    back_style = theme->getStyle("label.back");
}

void GuiLabel::onDraw(sp::RenderTarget& renderer)
{
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());
    
    if (background) renderer.drawStretched(rect, back.texture, back.color);

    renderer.drawText(rect, text, text_alignment, text_size, front.font, front.color, font_flag);
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
    font_flag |= sp::Font::FlagVertical;
    return this;
}

GuiLabel* GuiLabel::setUnwrapped()
{
    font_flag &= ~sp::Font::FlagLineWrap;
    return this;
}

GuiLabel* GuiLabel::setClipped()
{
    font_flag |= sp::Font::FlagClip;
    return this;
}

GuiAutoSizeLabel::GuiAutoSizeLabel(GuiContainer* owner, string id, string text, glm::vec2 min_size, glm::vec2 max_size, float min_text_size, float max_text_size)
: GuiLabel(owner, id, text, max_text_size), min_size(min_size), max_size(max_size), min_text_size(min_text_size), max_text_size(max_text_size)
{
}

void GuiAutoSizeLabel::onUpdate()
{
    auto font = front_style->get(getState()).font;
    text_size = max_text_size;
    glm::vec2 size;

    while (true)
    {
        size = min_size;
        auto pfs = font->prepare(text, 32, text_size, {255, 255, 255, 255}, size, text_alignment, font_flag);
        size = pfs.getUsedAreaSize();
        size.x = std::max(size.x, min_size.x);
        size.y = std::max(size.y, min_size.y);
        if (size.x <= max_size.x && size.y <= max_size.y) break;
        text_size -= 1.0f;
        if (text_size < min_text_size) break;
    }

    text_size = std::max(text_size, min_text_size);
    setSize(size);
}
