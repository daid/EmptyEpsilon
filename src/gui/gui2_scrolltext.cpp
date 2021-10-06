#include "main.h"
#include "gui2_scrolltext.h"


GuiScrollText::GuiScrollText(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30)
{
    auto_scroll_down = false;
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, sp::Alignment::TopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiScrollText* GuiScrollText::setText(string text)
{
    this->text = text;
    return this;
}

string GuiScrollText::getText() const
{
    return text;
}

GuiScrollText* GuiScrollText::setScrollbarWidth(float width)
{
    scrollbar->setSize(width, GuiElement::GuiSizeMax);
    return this;
}

void GuiScrollText::onDraw(sp::RenderTarget& renderer)
{
    auto text_rect = sp::Rect(rect.position.x, rect.position.y, rect.size.x - scrollbar->getSize().x, rect.size.y);
    auto prepared = main_font->prepare(this->text, 32, text_size, text_rect.size, sp::Alignment::TopLeft, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    auto text_draw_size = prepared.getUsedAreaSize();

    int scroll_max = text_draw_size.y;
    if (scrollbar->getMax() != scroll_max)
    {
        int diff = scroll_max - scrollbar->getMax();
        scrollbar->setRange(0, scroll_max);
        scrollbar->setValueSize(text_rect.size.y);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }

    if (text_rect.size.y >= text_draw_size.y)
    {
        scrollbar->hide();
        renderer.drawText(rect, this->text, sp::Alignment::TopLeft, text_size, main_font, selectColor(colorConfig.textbox.forground), sp::Font::FlagClip | sp::Font::FlagLineWrap);
    }
    else
    {
        for(auto& g : prepared.data)
            g.position.y -= scrollbar->getValue();
        scrollbar->show();
        renderer.drawText(text_rect, prepared, text_size, selectColor(colorConfig.textbox.forground), sp::Font::FlagClip | sp::Font::FlagLineWrap);
    }
}
