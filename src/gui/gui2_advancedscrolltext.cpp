#include "gui2_advancedscrolltext.h"

GuiAdvancedScrollText::GuiAdvancedScrollText(GuiContainer* owner, string id)
: GuiElement(owner, id), text_size(30.0f), rect_width(rect.size.x), max_prefix_width(0.0f)
{
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, sp::Alignment::TopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiAdvancedScrollText* GuiAdvancedScrollText::addEntry(string prefix, string text, glm::u8vec4 color, unsigned int seq)
{
    Entry& entry = entries.emplace_back();
    entry.prefix = prefix;
    entry.text = text;
    entry.color = color;
    entry.seq = seq;
    prepEntry(entry);
    return this;
}

unsigned int GuiAdvancedScrollText::getEntryCount() const
{
    return entries.size();
}

string GuiAdvancedScrollText::getEntryText(int index) const
{
    if (index < 0 || index >= static_cast<int>(getEntryCount()))
        return "";
    return entries[index].text;
}

GuiAdvancedScrollText::Entry GuiAdvancedScrollText::prepEntry(GuiAdvancedScrollText::Entry& e){
    e.prepared_prefix = sp::RenderTarget::getDefaultFont()->prepare(e.prefix, 32, text_size, rect.size, sp::Alignment::TopLeft);
    const float entry_prefix_width = e.prepared_prefix.getUsedAreaSize().x;
    prefix_widths[entry_prefix_width] += 1;
    max_prefix_width = std::max(max_prefix_width, entry_prefix_width);
    e.prepared_text = sp::RenderTarget::getDefaultFont()->prepare(e.text, 32, text_size, {rect.size.x - max_prefix_width - 50.0f, rect.size.y}, sp::Alignment::TopLeft, sp::Font::FlagLineWrap | sp::Font::FlagClip);
    return e;
}

unsigned int GuiAdvancedScrollText::getEntrySeq(int index) const
{
    if (index < 0 || index >= static_cast<int>(getEntryCount()))
        return 0;
    return entries[index].seq;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::removeEntry(int index)
{
    if (index < 0 || index >= static_cast<int>(getEntryCount()))
        return this;

    // Find new max prefix if entry was the last one with the current max
    const float entry_prefix_width = entries[index].prepared_prefix.getUsedAreaSize().x;
    bool last_with_width = false;
    if(--prefix_widths[entry_prefix_width] == 0){
        last_with_width = true;
        prefix_widths.erase(entry_prefix_width);
    }
    if (entry_prefix_width == max_prefix_width && last_with_width){
        max_prefix_width = prefix_widths.end()->first;
    }

    entries.erase(entries.begin() + index);

    return this;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::clearEntries()
{
    entries.clear();
    prefix_widths.clear();
    max_prefix_width = 0;
    return this;
}

void GuiAdvancedScrollText::onDraw(sp::RenderTarget& renderer)
{
    const bool is_resized = rect_width != rect.size.x;
    if (is_resized) {
        rect_width = rect.size.x;
        prefix_widths.clear();
        max_prefix_width = 0;
    }

    //Draw the visible entries
    float draw_offset = -scrollbar->getValue() + text_size + 12.0f;

    for(Entry& e : entries)
    {
        // Window width has changed. Re-prep fonts.
        if (is_resized){ prepEntry(e); }

        const float height = e.prepared_text.getUsedAreaSize().y;

        if (draw_offset + height > 0
            && draw_offset < rect.size.y)
        {
            const float y_start = e.prepared_prefix.data[0].position.y;

            for(auto& g : e.prepared_prefix.data)
            {
                g.position.y = draw_offset;
            }
            for(auto& g : e.prepared_text.data)
            {
                g.position.y = (g.position.y - y_start) + draw_offset;
            }
            renderer.drawText(rect, e.prepared_prefix, text_size, {255, 255, 255, 255}, sp::Font::FlagClip);
            renderer.drawText(sp::Rect(rect.position.x + max_prefix_width, rect.position.y, rect.size.x - 50 - max_prefix_width, rect.size.y), e.prepared_text, text_size, e.color, sp::Font::FlagClip);
        }

        draw_offset += height;
    }

    //Calculate how many lines we have to display in total.
    const int line_count = (draw_offset - text_size - 12.0f) + scrollbar->getValue();

    //Check if we need to update the scroll bar.
    if (scrollbar->getMax() != line_count)
    {
        const int diff = line_count - scrollbar->getMax();
        scrollbar->setRange(0, line_count);
        scrollbar->setValueSize(rect.size.y);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }
    scrollbar->setVisible(rect.size.y > 100);
}
