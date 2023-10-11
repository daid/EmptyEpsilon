#include "gui2_advancedscrolltext.h"

GuiAdvancedScrollText::GuiAdvancedScrollText(GuiContainer* owner, string id)
: GuiElement(owner, id), text_size(30)
{
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, sp::Alignment::TopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiAdvancedScrollText* GuiAdvancedScrollText::addEntry(string prefix, string text, glm::u8vec4 color, unsigned int seq)
{
    entries.emplace_back();
    entries.back().prefix = prefix;
    entries.back().text = text;
    entries.back().color = color;
    entries.back().seq = seq;
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

unsigned int GuiAdvancedScrollText::getEntrySeq(unsigned int index) const
{
    if (index >= getEntryCount())
        return 0;
    return entries[index].seq;
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

void GuiAdvancedScrollText::onDraw(sp::RenderTarget& renderer)
{
    //For all the entries, fix the maximum prefix width, so we know how much space we have for the text.
    float max_prefix_width = 0.0f;
    for(Entry& e : entries)
    {
        auto prepared = sp::RenderTarget::getDefaultFont()->prepare(e.prefix, 32, text_size, {0, 0}, sp::Alignment::TopLeft, 0);
        max_prefix_width = std::max(max_prefix_width, prepared.getUsedAreaSize().x);
    }

    //Draw the visible entries
    float draw_offset = -scrollbar->getValue();
    for(Entry& e : entries)
    {
        auto prepared_prefix = sp::RenderTarget::getDefaultFont()->prepare(e.prefix, 32, text_size, rect.size, sp::Alignment::TopLeft);
        auto prepared_text = sp::RenderTarget::getDefaultFont()->prepare(e.text, 32, text_size, {rect.size.x - max_prefix_width - 50, rect.size.y}, sp::Alignment::TopLeft, sp::Font::FlagLineWrap | sp::Font::FlagClip);
        auto height = prepared_text.getUsedAreaSize().y;
        if (draw_offset + height > 0)
        {
            for(auto& g : prepared_prefix.data)
                g.position.y += draw_offset;
            for(auto& g : prepared_text.data)
                g.position.y += draw_offset;
            renderer.drawText(rect, prepared_prefix, text_size, {255, 255, 255, 255}, sp::Font::FlagClip);
            renderer.drawText(sp::Rect(rect.position.x + max_prefix_width, rect.position.y, rect.size.x - 50 - max_prefix_width, rect.size.y), prepared_text, text_size, e.color, sp::Font::FlagClip);
        }
        draw_offset += height;
    }

    //Calculate how many lines we have to display in total.
    int line_count = draw_offset + scrollbar->getValue();

    //Check if we need to update the scroll bar.
    if (scrollbar->getMax() != line_count)
    {
        int diff = line_count - scrollbar->getMax();
        scrollbar->setRange(0, line_count);
        scrollbar->setValueSize(rect.size.y);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }
    scrollbar->setVisible(rect.size.y > 100);
}
