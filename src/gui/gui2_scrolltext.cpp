#include "main.h"
#include "gui2_scrolltext.h"

GuiScrollText::GuiScrollText(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30)
{
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, ATopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiScrollText* GuiScrollText::setText(string text)
{
    this->text = text;
    return this; 
}

void GuiScrollText::onDraw(sf::RenderTarget& window)
{
    string text = this->text;
    int line_count = 1;
    {
        float currentOffset = 0;
        bool firstWord = true;
        std::size_t wordBegining = 0;

        for (std::size_t pos(0); pos < text.length(); ++pos)
        {
            char currentChar = text[pos];
            if (currentChar == '\n')
            {
                currentOffset = 0;
                firstWord = true;
                line_count += 1;
                continue;
            }
            else if (currentChar == ' ')
            {
                wordBegining = pos;
                firstWord = false;
            }

            sf::Glyph glyph = mainFont.getGlyph(currentChar, text_size, false);
            currentOffset += glyph.advance;

            if (!firstWord && currentOffset > rect.width - 50)
            {
                pos = wordBegining;
                text[pos] = '\n';
                firstWord = true;
                currentOffset = 0;
                line_count += 1;
            }
        }
    }
    
    int start_pos = 0;
    for(int n=0; n<scrollbar->getValue(); n++)
    {
        int next = text.find("\n", start_pos) + 1;
        if (next > 0)
            start_pos = next;
    }
    if (start_pos > 0)
        text = text.substr(start_pos);
    int max_lines = rect.height / mainFont.getLineSpacing(text_size);
    if (line_count - scrollbar->getValue() > max_lines)
    {
        int end_pos = 0;
        for(int n=0; n<max_lines; n++)
        {
            int next = text.find("\n", end_pos) + 1;
            if (next > 0)
                end_pos = next;
        }
        if (end_pos > 0)
            text = text.substr(0, end_pos);
    }
    
    if (scrollbar->getMax() != line_count)
    {
        int diff = line_count - scrollbar->getMax();
        scrollbar->setRange(0, line_count);
        scrollbar->setValueSize(max_lines);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }

    drawText(window, sf::FloatRect(rect.left, rect.top, rect.width - 50, rect.height), text, ATopLeft, text_size, sf::Color::White);
}
