#include "gui2_scrolltext.h"
#include "theme.h"


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
    auto prepared = sp::RenderTarget::getDefaultFont()->prepare(this->text, 32, text_size, selectColor(colorConfig.textbox.forground), text_rect.size, sp::Alignment::TopLeft, sp::Font::FlagClip | sp::Font::FlagLineWrap);
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
        renderer.drawText(rect, prepared, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    }
    else
    {
        for(auto& g : prepared.data)
            g.position.y -= scrollbar->getValue();
        scrollbar->show();
        renderer.drawText(text_rect, prepared, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    }
}


GuiScrollFormattedText::GuiScrollFormattedText(GuiContainer* owner, string id, string text)
: GuiScrollText(owner, id, text)
{
}

void GuiScrollFormattedText::onDraw(sp::RenderTarget& renderer)
{
    auto main_color = selectColor(colorConfig.textbox.forground);
    auto current_color = main_color;
    auto text_rect = sp::Rect(rect.position.x, rect.position.y, rect.size.x - scrollbar->getSize().x, rect.size.y);
    auto prepared = sp::RenderTarget::getDefaultFont()->start(32, text_rect.size, sp::Alignment::TopLeft, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    int last_end = 0;
    float size_mod = 1.0f;
    for(auto tag_start = text.find('<'); tag_start >= 0; tag_start = text.find('<', tag_start+1)) {
        prepared.append(text.substr(last_end, tag_start), text_size * size_mod, current_color);
        auto tag_end = text.find('>', tag_start+1);
        if (tag_end != -1) {
            last_end = tag_end + 1;
            auto tag = text.substr(tag_start + 1, tag_end);
            if (tag == "/") {
                size_mod = 1.0f;
                current_color = main_color;
            } else if (tag == "h1") {
                size_mod = 2.0f;
            } else if (tag == "h2") {
                size_mod = 1.5f;
            } else if (tag == "h3") {
                size_mod = 1.17f;
            } else if (tag == "h4") {
                size_mod = 1.0f;
            } else if (tag == "h5") {
                size_mod = 0.83f;
            } else if (tag == "h6") {
                size_mod = 0.67f;
            } else if (tag == "small") {
                size_mod = 0.89f;
            } else if (tag == "large") {
                size_mod = 1.2f;
            } else if (tag.startswith("color=")) {
                current_color = GuiTheme::toColor(tag.substr(6));
            } else {
                last_end = tag_start;
            }
        }
    }
    prepared.append(text.substr(last_end), text_size, current_color);
    prepared.finish();
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
        renderer.drawText(rect, prepared, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    }
    else
    {
        for(auto& g : prepared.data)
            g.position.y -= scrollbar->getValue();
        scrollbar->show();
        renderer.drawText(text_rect, prepared, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    }
}