#pragma once

#include "gui2_scrollcontainer.h"

// A GuiScrollContainer for log-like scrolling text composed of individual,
// formatted entries, each with a prefix. Used for the ship's log control.
// For typical scrolling text usage, use GuiScrollText instead.
class GuiAdvancedScrollText : public GuiScrollContainer
{
protected:
    // Defines an entry to add to the text, including its prefix, color, and
    // order in the list.
    class Entry
    {
    public:
        string prefix;
        sp::Font::PreparedFontString prepared_prefix;
        string text;
        sp::Font::PreparedFontString prepared_text;
        glm::u8vec4 color;
        unsigned int seq;
    };
    // A vector of Entries to render as text.
    std::vector<Entry> entries;

    // Base font size, in virtual pixels.
    float text_size = 30.0f;
    // Define the maximum width of the prefix column, in virtual pixels.
    float max_prefix_width = 0.0f;
    // Map custom prefix widths to entries.
    std::map<float, int> prefix_widths;
    // Determines whether to automatically scroll text to the bottom when the
    // text changes.
    bool auto_scroll_down = false;
    // Sets the mouse scroll interval as the number of scrollbar steps from top
    // to bottom. (Not implemented yet)
    int mouse_scroll_steps = 25;

    // Prepare an entry's prefix string for the given canvas width. Doesn't
    // update prefix_widths or max_prefix_width.
    void prepEntryPrefix(Entry& e, float canvas_width);
    // Prepare an entry's text string for the given column width.
    void prepEntryText(Entry& e, float text_column_width);

    // Inner element that renders all entries and auto-sizes its height, allowing
    // GuiScrollContainer to clip and scroll the content.
    class EntryCanvas : public GuiElement
    {
    public:
        EntryCanvas(GuiAdvancedScrollText* owner, const string& id);
        virtual void onDraw(sp::RenderTarget& renderer) override;
    private:
        // Track the canvas width for resizing.
        float prev_canvas_width = 0.0f;
    };
    EntryCanvas* entry_canvas;

public:
    GuiAdvancedScrollText(GuiContainer* owner, string id);

    // Enables automatic scrolling to the bottom when the text changes.
    GuiAdvancedScrollText* enableAutoScrollDown() { auto_scroll_down = true; return this; }
    // Disables automatic scrolling to the bottom when the text changes.
    GuiAdvancedScrollText* disableAutoScrollDown() { auto_scroll_down = false; return this; }
    // Adds an entry to the list at the given sequence order.
    GuiAdvancedScrollText* addEntry(string prefix, string text, glm::u8vec4 color, unsigned int seq);
    // Sets the font size to a value of at least 1px.
    GuiAdvancedScrollText* setTextSize(float text_size);

    // Returns the number of recorded entries.
    unsigned int getEntryCount() const;
    // Returns the text of the entry with the given index.
    string getEntryText(int index) const;
    // Returns the sequential order value of the entry with the given index.
    unsigned int getEntrySeq(int index) const;
    // Removes the entry with the given index.
    GuiAdvancedScrollText* removeEntry(int index);
    // Removes all entries from the list.
    GuiAdvancedScrollText* clearEntries();
};
