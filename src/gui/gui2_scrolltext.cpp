#include "gui2_scrolltext.h"
#include "theme.h"

GuiScrollText::GuiScrollText(GuiContainer* owner, string id, string text)
: GuiScrollContainer(owner, id), text(text)
{
    text_element = new GuiMultilineText(this, "", text);
    text_element
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

GuiScrollText* GuiScrollText::setText(string text)
{
    this->text = text;
    if (text_element) text_element->setText(text);
    if (auto_scroll_down) scrollToFraction(1.0f);
    return this;
}

GuiScrollFormattedText::GuiScrollFormattedText(GuiContainer* owner, string id, string text)
: GuiScrollText(owner, id, text)
{
    // Replace the plain text element created by the base constructor with a
    // formatted one. Mark the old element for deletion and reassign text_element
    // so base class methods (setText, setTextSize) work through the new element.
    text_element->destroy();
    text_element = new GuiMultilineFormattedText(this, "", text);
    text_element
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}
