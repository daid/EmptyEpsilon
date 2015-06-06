#include "gui2_label.h"

GuiLabel::GuiLabel(GuiContainer* owner, string id, string text, float text_size)
: GuiElement(owner, id), text(text), text_size(text_size), text_alignment(ACenter)
{
}

void GuiLabel::onDraw(sf::RenderTarget& window)
{
    drawText(window, rect, text, text_alignment, text_size);
}

GuiLabel* GuiLabel::setText(string text)
{
    this->text = text;
    return this;
}

GuiLabel* GuiLabel::setAlignment(EGuiAlign alignment)
{
    text_alignment = alignment;
    return this;
}
