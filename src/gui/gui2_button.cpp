#include "gui2_button.h"

GuiButton::GuiButton(GuiContainer* owner, string id, string text, func_t func)
: GuiElement(owner, id), text(text), func(func)
{
    text_size = 30;
    button_color = sf::Color::White;
}

void GuiButton::onDraw(sf::RenderTarget& window)
{
    sf::Color color = button_color;
    if (!enabled)
        color = color * sf::Color(96, 96, 96, 255);
    else if (has_focus)
        color = color * sf::Color(128, 128, 128, 255);
    draw9Cut(window, rect, "button_background", color);
    drawText(window, rect, text, ACenter, text_size, sf::Color::Black);
}

bool GuiButton::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiButton::onMouseUp(sf::Vector2f position)
{
    soundManager.playSound("button.wav");
    if (func)
        func(this);
}

string GuiButton::getText()
{
    return text;
}

GuiButton* GuiButton::setText(string text)
{
    this->text = text;
    return this;
}

GuiButton* GuiButton::setColor(sf::Color color)
{
    button_color = color;
    return this;
}
