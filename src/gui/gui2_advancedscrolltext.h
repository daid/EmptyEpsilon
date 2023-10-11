#ifndef GUI2_ADVANCEDSCROLLTEXT_H
#define GUI2_ADVANCEDSCROLLTEXT_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

class GuiAdvancedScrollText : public GuiElement
{
protected:
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

    std::vector<Entry> entries;
    GuiScrollbar* scrollbar;
    float text_size;
    float rect_width;
    float max_prefix_width;
    std::map<float, int> prefix_widths;
    bool auto_scroll_down;
    Entry prepEntry(Entry& e);

public:
    GuiAdvancedScrollText(GuiContainer* owner, string id);

    GuiAdvancedScrollText* enableAutoScrollDown() { auto_scroll_down = true; return this; }
    GuiAdvancedScrollText* disableAutoScrollDown() { auto_scroll_down = false; return this; }

    GuiAdvancedScrollText* addEntry(string prefix, string text, glm::u8vec4 color, unsigned int seq);
    GuiAdvancedScrollText* setTextSize(float text_size) { this->text_size = text_size; return this; }

    unsigned int getEntryCount() const;
    string getEntryText(int index) const;
    unsigned int getEntrySeq(int index) const;
    GuiAdvancedScrollText* removeEntry(int index);
    GuiAdvancedScrollText* clearEntries();

    virtual void onDraw(sp::RenderTarget& renderer) override;
};

#endif//GUI2_ADVANCEDSCROLLTEXT_H
