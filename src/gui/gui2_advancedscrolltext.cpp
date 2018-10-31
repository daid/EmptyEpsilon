#include "main.h"
#include "gui2_advancedscrolltext.h"

GuiAdvancedScrollText::GuiAdvancedScrollText(GuiContainer* owner, string id)
: GuiElement(owner, id), text_size(30)
{
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, ATopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiAdvancedScrollText* GuiAdvancedScrollText::addEntry(string prefix, string text, sf::Color color)
{
    entries.emplace_back();
    entries.back().prefix = prefix;
    entries.back().text = text;
    entries.back().color = color;
    return this; 
}

unsigned int GuiAdvancedScrollText::getEntryCount() const
{
    return entries.size();
}

string GuiAdvancedScrollText::getEntryText(int index) const
{
    if (index < 0 || index >= int(getEntryCount()))
        return "";
    return entries[index].text;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::removeEntry(int index)
{
    if (index < 0 || index > int(getEntryCount()))
        return this;
    entries.erase(entries.begin() + index);
    return this;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::clearEntries()
{
    entries.clear();
    return this;
}

void GuiAdvancedScrollText::onDraw(sf::RenderTarget& window)
{
    float line_spacing = main_font->getLineSpacing(text_size);

    //For all the entries, fix the maximum prefix width, so we know how much space we have for the text.
    float max_prefix_width = 0.0f;
    for(Entry& e : entries)
    {
        float width = 0.0f;
        for(char c : e.prefix)
        {
            sf::Glyph glyph = main_font->getGlyph(c, text_size, false);
            width += glyph.advance;
        }
        max_prefix_width = std::max(max_prefix_width, width);
    }
    
    //Calculate how many lines we can display properly
    int max_lines = rect.height / line_spacing;
    
    //Draw the visible entries
    int draw_offset = -scrollbar->getValue();
    for(Entry& e : entries)
    {
        LineWrapResult wrap = doLineWrap(e.text, text_size, rect.width - 50 - max_prefix_width);
        if (draw_offset >= 0 && draw_offset < max_lines)
        {
            drawText(window, sf::FloatRect(rect.left, rect.top + line_spacing * draw_offset, rect.width - 50, rect.height), e.prefix, ATopLeft, text_size);
        }
        for(string line : wrap.text.split("\n"))
        {
            if (draw_offset >= 0 && draw_offset < max_lines)
            {
                drawText(window, sf::FloatRect(rect.left + max_prefix_width, rect.top + line_spacing * draw_offset, rect.width - 50 - max_prefix_width, rect.height), line, ATopLeft, text_size, main_font, e.color);
            }
            draw_offset += 1;
        }
    }

    //Calculate how many lines we have to display in total.
    int line_count = draw_offset + scrollbar->getValue();

    //Check if we need to update the scroll bar.
    if (scrollbar->getMax() != line_count)
    {
        int diff = line_count - scrollbar->getMax();
        scrollbar->setRange(0, line_count);
        scrollbar->setValueSize(max_lines);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }
    scrollbar->setVisible(rect.height > 100);
}
