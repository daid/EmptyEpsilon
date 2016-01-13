#ifndef GUI2_ADVANCED_SCROLL_TEST_H
#define GUI2_ADVANCED_SCROLL_TEST_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

class GuiAdvancedScrollText : public GuiElement
{
protected:
    class Entry
    {
    public:
        string prefix;
        string text;
        sf::Color color;
    };
    
    std::vector<Entry> entries;
    GuiScrollbar* scrollbar;
    float text_size;
    bool auto_scroll_down;
public:
    GuiAdvancedScrollText(GuiContainer* owner, string id);
    
    GuiAdvancedScrollText* enableAutoScrollDown() { auto_scroll_down = true; return this; }
    GuiAdvancedScrollText* disableAutoScrollDown() { auto_scroll_down = false; return this; }

    GuiAdvancedScrollText* addEntry(string prefix, string text, sf::Color color);
    GuiAdvancedScrollText* setTextSize(float text_size) { this->text_size = text_size; return this; }
    
    unsigned int getEntryCount();
    string getEntryText(int index);
    GuiAdvancedScrollText* removeEntry(int index);
    GuiAdvancedScrollText* clearEntries();

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI2_ADVANCED_SCROLL_TEST_H
