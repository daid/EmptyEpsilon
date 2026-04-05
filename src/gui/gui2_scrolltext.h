#pragma once

#include "gui2_scrollcontainer.h"
#include "gui2_multilinetext.h"

// A GuiScrollContainer wrapper for GuiMultilineText that maintains backward
// compatibility with legacy GuiScrollText.
class GuiScrollText : public GuiScrollContainer
{
protected:
    // The text to render. Passed directly to GuiMultilineText.
    string text;
    // Base font size, in virtual pixels. Passed directly to GuiMultilineText.
    float text_size = 30.0f;
    // Determines whether to automatically scroll text to the bottom when the
    // text changes.
    bool auto_scroll_down = false;
    // Sets the mouse scroll interval as the number of scrollbar steps from top
    // to bottom. (Not implemented yet)
    int mouse_scroll_steps = 25;
    // The multiline text element. GuiScrollFormattedText overwrites this with a
    // GuiMultilineFormattedText element.
    GuiMultilineText* text_element;

public:
    GuiScrollText(GuiContainer* owner, string id, string text);

    // Enables automatic scrolling to the bottom when the text changes.
    GuiScrollText* enableAutoScrollDown() { auto_scroll_down = true; return this; }
    // Disables automatic scrolling to the bottom when the text changes.
    GuiScrollText* disableAutoScrollDown() { auto_scroll_down = false; return this; }

    // Sets the element's text contents. Use control characters like \n to add
    // line breaks. If automatic scrolling is enabled, this triggers it.
    GuiScrollText* setText(string text);
    // Returns the element's text.
    string getText() const { return text; }
    // Sets the font size to a value of at least 1px.
    GuiScrollText* setTextSize(float text_size) { text_element->setTextSize(text_size); return this; }
};

// A GuiScrollText wrapper for GuiMultilineFormattedText, reusing everything but
// text_element.
class GuiScrollFormattedText : public GuiScrollText
{
public:
    GuiScrollFormattedText(GuiContainer* owner, string id, string text);
};
