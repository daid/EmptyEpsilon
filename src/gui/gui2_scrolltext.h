#ifndef GUI_SCROLL_TEXT_H
#define GUI_SCROLL_TEXT_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

class GuiScrollText : public GuiElement
{
protected:
    GuiScrollbar* scrollbar;
    string text;
    float text_size;
    bool auto_scroll_down;
public:
    GuiScrollText(GuiContainer* owner, string id, string text);
    
    GuiScrollText* enableAutoScrollDown() { auto_scroll_down = true; return this; }
    GuiScrollText* disableAutoScrollDown() { auto_scroll_down = false; return this; }

    GuiScrollText* setText(string text);
    GuiScrollText* setTextSize(float text_size) { this->text_size = text_size; return this; }

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SCROLL_TEXT_H
