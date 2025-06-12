#ifndef GUI_SCROLLTEXT_H
#define GUI_SCROLLTEXT_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

class GuiScrollText : public GuiElement
{
protected:
    GuiScrollbar* scrollbar;
    string text;
    float text_size;
    bool auto_scroll_down;
    int mouse_scroll_steps;

public:
    GuiScrollText(GuiContainer* owner, string id, string text);

    GuiScrollText* enableAutoScrollDown() { auto_scroll_down = true; return this; }
    GuiScrollText* disableAutoScrollDown() { auto_scroll_down = false; return this; }

    GuiScrollText* setText(string text);
    string getText() const;
    GuiScrollText* setTextSize(float text_size) { this->text_size = text_size; return this; }

    GuiScrollText* setScrollbarWidth(float width);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual void onMouseWheelScroll(glm::vec2 position, float value) override;
};

class GuiScrollFormattedText : public GuiScrollText
{
public:
    GuiScrollFormattedText(GuiContainer* owner, string id, string text);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual void onMouseWheelScroll(glm::vec2 position, float value) override;
};

#endif//GUI_SCROLLTEXT_H
