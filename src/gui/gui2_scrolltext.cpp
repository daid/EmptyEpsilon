#include "main.h"
#include "gui2_scrolltext.h"

GuiScrollText::GuiScrollText(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30)
{
    auto_scroll_down = false;
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, ATopRight)->setSize(50, GuiElement::GuiSizeMax);
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

void GuiScrollText::onDraw(sf::RenderTarget& window)
{
    LineWrapResult wrap = doLineWrap(this->text, text_size, rect.width - scrollbar->getSize().x);
    
    int start_pos = 0;
    for(int n=0; n<scrollbar->getValue(); n++)
    {
        int next = wrap.text.find("\n", start_pos) + 1;
        if (next > 0)
            start_pos = next;
    }
    if (start_pos > 0)
        wrap.text = wrap.text.substr(start_pos);
    int max_lines = rect.height / main_font->getLineSpacing(text_size);
    if (wrap.line_count - scrollbar->getValue() > max_lines)
    {
        int end_pos = 0;
        for(int n=0; n<max_lines; n++)
        {
            int next = wrap.text.find("\n", end_pos) + 1;
            if (next > 0)
                end_pos = next;
        }
        if (end_pos > 0)
            wrap.text = wrap.text.substr(0, end_pos);
    }
    
    if (scrollbar->getMax() != wrap.line_count)
    {
        int diff = wrap.line_count - scrollbar->getMax();
        scrollbar->setRange(0, wrap.line_count);
        scrollbar->setValueSize(max_lines);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }

    drawText(window, sf::FloatRect(rect.left, rect.top, rect.width - scrollbar->getSize().x, rect.height), wrap.text, ATopLeft, text_size, main_font, selectColor(colorConfig.textbox.forground));
}
