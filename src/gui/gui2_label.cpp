#include "gui2_label.h"

GuiLabel::GuiLabel(GuiContainer* owner, string id, string text, float text_size)
: GuiElement(owner, id), text(text), text_size(text_size), text_color(sf::Color::White), text_alignment(ACenter), background(false), vertical(false)
{
}

void GuiLabel::onDraw(sf::RenderTarget& window)
{
    if (background)
        drawStretched(window, rect, "gui/LabelBackground", selectColor(colorConfig.label.background));
    sf::Color color = selectColor(colorConfig.label.forground);
    if (vertical)
        drawVerticalText(window, rect, text, text_alignment, text_size, main_font, color);
    else
        drawText(window, rect, text, text_alignment, text_size, main_font, color);
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

GuiLabel* GuiLabel::addBackground()
{
    background = true;
    return this;
}

GuiLabel* GuiLabel::setVertical()
{
    vertical = true;
    return this;
}
