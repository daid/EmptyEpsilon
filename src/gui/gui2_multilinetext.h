#pragma once

#include "gui2_element.h"

class GuiThemeStyle;

// A GuiElement that renders multiline text within its bounds, and without
// scrolling or clipping. To scroll or clip multiline text, instead use
// GuiScrollText.
class GuiMultilineText : public GuiElement
{
protected:
    // The text to render.
    string text;
    // Base font size, in virtual pixels.
    float text_size = 30.0f;
    // Theme for text foreground properties.
    const GuiThemeStyle* text_theme;

public:
    GuiMultilineText(GuiContainer* owner, string id, string text);

    // Sets the element's text contents. Use control characters like \n to add
    // line breaks.
    GuiMultilineText* setText(string text);
    // Returns the element's text.
    string getText() const;
    // Sets the font size to a value of at least 1px.
    GuiMultilineText* setTextSize(float text_size) { this->text_size = std::max(1.0f, text_size); return this; }

    // Prepares and renders the text.
    virtual void onDraw(sp::RenderTarget& renderer) override;
};

// A GuiMultilineText that also uses formatting tags to format the text.
// To scroll or clip formatted text, use GuiScrollFormattedText.
class GuiMultilineFormattedText : public GuiMultilineText
{
public:
    GuiMultilineFormattedText(GuiContainer* owner, string id, string text);

    // Overrides GuiMultilineText to apply formatting tags and incrementally
    // prepare the text.
    virtual void onDraw(sp::RenderTarget& renderer) override;
};
