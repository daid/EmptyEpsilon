#include "gui2_label.h"

GuiLabel::GuiLabel(GuiContainer* owner, string id, string text, float text_size)
: GuiElement(owner, id), text(text), text_size(text_size), text_color(sf::Color::White), text_alignment(ACenter), box(false), vertical(false)
{
}

void GuiLabel::onDraw(sf::RenderTarget& window)
{
    if (box)
        draw9Cut(window, rect, "border_background", sf::Color::White);
    if (vertical)
        drawVerticalText(window, rect, text, text_alignment, text_size, text_color);
    else
        drawText(window, rect, text, text_alignment, text_size, text_color);
}

GuiLabel* GuiLabel::setText(string text)
{
    this->text = text;
    return this;
}

string GuiLabel::getText()
{
    return text;
}

GuiLabel* GuiLabel::setAlignment(EGuiAlign alignment)
{
    text_alignment = alignment;
    return this;
}

GuiLabel* GuiLabel::setTextColor(sf::Color color)
{
    text_color = color;
    return this;
}

GuiLabel* GuiLabel::addBox()
{
    box = true;
    return this;
}

GuiLabel* GuiLabel::setVertical()
{
    vertical = true;
    return this;
}
