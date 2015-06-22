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

    void setText(string text);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SCROLL_TEXT_H
