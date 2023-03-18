#include "gui2_advancedscrolltext.h"

GuiAdvancedScrollText::GuiAdvancedScrollText(GuiContainer* owner, string id)
: GuiElement(owner, id), text_size(30.0f), rect_width(rect.size.x), max_prefix_width(0.0f)
{
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, sp::Alignment::TopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiAdvancedScrollText* GuiAdvancedScrollText::addEntry(string prefix, string text, glm::u8vec4 color)
{
    Entry& entry = entries.emplace_back();
    entry.prefix = prefix;
    entry.prepared_prefix = sp::RenderTarget::getDefaultFont()->prepare(prefix, 32, text_size, rect.size, sp::Alignment::TopLeft);
    max_prefix_width = std::max(max_prefix_width, entry.prepared_prefix.getUsedAreaSize().x);
    entry.text = text;
    entry.prepared_text = sp::RenderTarget::getDefaultFont()->prepare(text, 32, text_size, {rect.size.x - max_prefix_width - 50.0f, rect.size.y}, sp::Alignment::TopLeft, sp::Font::FlagLineWrap | sp::Font::FlagClip);
    entry.color = color;
    // For each entry, fix the maximum prefix width, so we know how much space we have for the text.
    return this;
}

unsigned int GuiAdvancedScrollText::getEntryCount() const
{
    return entries.size();
}

string GuiAdvancedScrollText::getEntryText(unsigned int index) const
{
    if (index >= getEntryCount())
        return "";
    return entries[index].text;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::removeEntry(unsigned int index)
{
    if (index > getEntryCount())
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
    const bool is_resized = rect_width != rect.size.x;
    if (is_resized) { rect_width = rect.size.x; }

    //Draw the visible entries
    float draw_offset = -scrollbar->getValue() + text_size + 12.0f;

    for(Entry& e : entries)
    {
        if (is_resized)
        {
            // Window width has changed. Re-prep fonts.
            e.prepared_prefix = sp::RenderTarget::getDefaultFont()->prepare(e.prefix, 32, text_size, rect.size, sp::Alignment::TopLeft);
            max_prefix_width = std::max(max_prefix_width, e.prepared_prefix.getUsedAreaSize().x);
            e.prepared_text = sp::RenderTarget::getDefaultFont()->prepare(e.text, 32, text_size, {rect.size.x - max_prefix_width - 50.0f, rect.size.y}, sp::Alignment::TopLeft, sp::Font::FlagLineWrap | sp::Font::FlagClip);
        }

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
    const int line_count = draw_offset + scrollbar->getValue();

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
