#include "gui2_advancedscrolltext.h"

GuiAdvancedScrollText::GuiAdvancedScrollText(GuiContainer* owner, string id)
: GuiScrollContainer(owner, id)
{
    entry_canvas = new EntryCanvas(this, id + "_CANVAS");
    entry_canvas->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

GuiAdvancedScrollText::EntryCanvas::EntryCanvas(GuiAdvancedScrollText* owner, const string& id)
: GuiElement(owner, id)
{
}

void GuiAdvancedScrollText::EntryCanvas::onDraw(sp::RenderTarget& renderer)
{
    auto* scroll_text = static_cast<GuiAdvancedScrollText*>(owner);

    // Re-prep all entries if the canvas width has changed. Two passes: first
    // collect prefix widths to find the max, then prep text with that width.
    if (prev_canvas_width != rect.size.x)
    {
        prev_canvas_width = rect.size.x;
        scroll_text->prefix_widths.clear();
        scroll_text->max_prefix_width = 0.0f;

        for (auto& e : scroll_text->entries)
        {
            scroll_text->prepEntryPrefix(e, prev_canvas_width);
            const float pw = e.prepared_prefix.getUsedAreaSize().x;
            scroll_text->prefix_widths[pw] += 1;
            scroll_text->max_prefix_width = std::max(scroll_text->max_prefix_width, pw);
        }

        const float text_col_width = prev_canvas_width - scroll_text->max_prefix_width;
        for (auto& e : scroll_text->entries)
            scroll_text->prepEntryText(e, text_col_width);
    }

    // Render entries stacked top-to-bottom, preserving the leading gap from the
    // original implementation so that ascenders of the first line are visible.
    float y_offset = scroll_text->text_size + 12.0f;

    for (auto& e : scroll_text->entries)
    {
        const float height = e.prepared_text.getUsedAreaSize().y;
        const float y_start = e.prepared_prefix.data.empty() ? 0.0f
            : e.prepared_prefix.data[0].position.y;

        // Copy prepared strings and remap their y positions to y_offset.
        auto draw_prefix = e.prepared_prefix;
        auto draw_text = e.prepared_text;

        for (auto& g : draw_prefix.data)
            g.position.y = y_offset;
        for (auto& g : draw_text.data)
            g.position.y = (g.position.y - y_start) + y_offset;

        renderer.drawText(rect, draw_prefix);
        renderer.drawText(
            sp::Rect{
                rect.position.x + scroll_text->max_prefix_width,
                rect.position.y,
                rect.size.x - scroll_text->max_prefix_width,
                rect.size.y
            },
            draw_text
        );

        y_offset += height;
    }

    // Auto-size the canvas height to fit all entries.
    setSize(GuiElement::GuiSizeMax, y_offset);
    layout.fill_height = false;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::addEntry(string prefix, string text, glm::u8vec4 color, unsigned int seq)
{
    Entry& entry = entries.emplace_back();
    entry.prefix = prefix;
    entry.text = text;
    entry.color = color;
    entry.seq = seq;

    const float canvas_width = entry_canvas->getRect().size.x;

    // Prep the prefix to get its width.
    prepEntryPrefix(entry, canvas_width);
    const float new_prefix_width = entry.prepared_prefix.getUsedAreaSize().x;
    prefix_widths[new_prefix_width] += 1;

    if (new_prefix_width > max_prefix_width)
    {
        // New prefix is wider: re-prep all existing entries' text with the
        // narrower text column.
        max_prefix_width = new_prefix_width;
        const float text_col_width = canvas_width - max_prefix_width;
        for (auto& e : entries)
            prepEntryText(e, text_col_width);
    }
    else
    {
        prepEntryText(entry, canvas_width - max_prefix_width);
    }

    if (auto_scroll_down) scrollToFraction(1.0f);
    return this;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::setTextSize(float new_text_size)
{
    text_size = std::max(1.0f, new_text_size);

    // Re-prep all entries with the new text size. The EntryCanvas::onDraw
    // resize path will also catch this on next draw if canvas width changed,
    // but we force it here for the height-only case.
    const float canvas_width = entry_canvas->getRect().size.x;
    if (canvas_width > 0.0f)
    {
        prefix_widths.clear();
        max_prefix_width = 0.0f;

        for (auto& e : entries)
        {
            prepEntryPrefix(e, canvas_width);
            const float pw = e.prepared_prefix.getUsedAreaSize().x;
            prefix_widths[pw] += 1;
            max_prefix_width = std::max(max_prefix_width, pw);
        }

        const float text_col_width = canvas_width - max_prefix_width;
        for (auto& e : entries)
            prepEntryText(e, text_col_width);
    }

    return this;
}

void GuiAdvancedScrollText::prepEntryPrefix(Entry& e, float canvas_width)
{
    e.prepared_prefix = sp::RenderTarget::getDefaultFont()->prepare(
        e.prefix, 32, text_size, {255, 255, 255, 255},
        {canvas_width, 10000.0f}, sp::Alignment::TopLeft
    );
}

void GuiAdvancedScrollText::prepEntryText(Entry& e, float text_column_width)
{
    e.prepared_text = sp::RenderTarget::getDefaultFont()->prepare(
        e.text, 32, text_size, e.color,
        {text_column_width, 10000.0f},
        sp::Alignment::TopLeft, sp::Font::FlagLineWrap
    );
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

    const float entry_prefix_width = entries[index].prepared_prefix.getUsedAreaSize().x;
    if (--prefix_widths[entry_prefix_width] == 0)
    {
        prefix_widths.erase(entry_prefix_width);
        if (entry_prefix_width == max_prefix_width)
            max_prefix_width = prefix_widths.empty() ? 0.0f : prefix_widths.rbegin()->first;
    }

    entries.erase(entries.begin() + index);
    return this;
}

GuiAdvancedScrollText* GuiAdvancedScrollText::clearEntries()
{
    entries.clear();
    prefix_widths.clear();
    max_prefix_width = 0.0f;
    return this;
}
