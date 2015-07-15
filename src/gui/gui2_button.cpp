#include "soundManager.h"
#include "gui2_button.h"

GuiButton::GuiButton(GuiContainer* owner, string id, string text, func_t func)
: GuiElement(owner, id), text(text), func(func), hotkey(sf::Keyboard::Unknown)
{
    text_size = 30;
    button_color = sf::Color::White;
}

void GuiButton::onDraw(sf::RenderTarget& window)
{
    sf::Color color = button_color;
    if (!enabled)
        color = color * sf::Color(96, 96, 96, 255);
    else if (hover)
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
    if (rect.contains(position))
    {
        soundManager.playSound("button.wav");
        if (func)
            func();
    }
}

bool GuiButton::onHotkey(sf::Keyboard::Key key, int unicode)
{
    if (key == hotkey)
    {
        if (func)
            func();
        return true;
    }
    return false;
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

GuiButton* GuiButton::setHotkey(sf::Keyboard::Key key)
{
    hotkey = key;
    return this;
}

GuiButton* GuiButton::setTextSize(float size)
{
    text_size = size;
    return this;
}
