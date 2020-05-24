#include "gui2_textentry.h"
#include "input.h"

GuiTextEntry::GuiTextEntry(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30), func(nullptr), enter_func(nullptr), validator_func(nullptr), valid(true)
{
}

void GuiTextEntry::onDraw(sf::RenderTarget& window)
{
    if (focus)
        drawStretched(window, rect, "gui/TextEntryBackground.focused", selectColor(colorConfig.text_entry.background));
    else
        drawStretched(window, rect, "gui/TextEntryBackground", selectColor(colorConfig.text_entry.background));
    bool typing_indicator = focus;
    const float blink_rate = 0.530;
    if (blink_clock.getElapsedTime().asSeconds() < blink_rate)
        typing_indicator = false;
    if (blink_clock.getElapsedTime().asSeconds() > blink_rate * 2.0f)
        blink_clock.restart();
    drawText(window, sf::FloatRect(rect.left + 16, rect.top, rect.width, rect.height), text + (typing_indicator ? "_" : ""), ACenterLeft, text_size, main_font, selectColor(colorConfig.text_entry.forground));
}

bool GuiTextEntry::onMouseDown(sf::Vector2f position)
{
    return true;
}

bool GuiTextEntry::onKey(sf::Event::KeyEvent key, int unicode)
{
    if (key.code == sf::Keyboard::BackSpace && text.length() > 0)
    {
        text = text.substr(0, -1);
        if (validator_func)
        {
            Validator v = validator_func;
            valid = v(text);
        }
        if (func)
        {
            func_t f = func;
            f(text);
        }
        return true;
    }
    if (key.code == sf::Keyboard::Return)
    {
        if (enter_func)
        {
            func_t f = enter_func;
            f(text);
        }
        return true;
    }
    if (key.code == sf::Keyboard::V && key.control)
    {
        for(int unicode : Clipboard::readClipboard())
        {
            if (unicode > 31 && unicode < 128)
                text += string(char(unicode));
        }
        if (validator_func)
        {
            Validator v = validator_func;
            valid = v(text);
        }
        if (func)
        {
            func_t f = func;
            f(text);
        }
        return true;
    }
    if (unicode > 31 && unicode < 128)
    {
        text += string(char(unicode));
        if (validator_func)
        {
            Validator v = validator_func;
            valid = v(text);
        }
        if (func)
        {
            func_t f = func;
            f(text);
        }
        return true;
    }
    return true;
}

void GuiTextEntry::onFocusGained()
{
    sf::Keyboard::setVirtualKeyboardVisible(true);
}

void GuiTextEntry::onFocusLost()
{
    sf::Keyboard::setVirtualKeyboardVisible(false);
}

bool GuiTextEntry::isValid() const
{
    return valid;
}

string GuiTextEntry::getText() const
{
    return text;
}

GuiTextEntry* GuiTextEntry::setText(string text)
{
    this->text = text;
    if (validator_func)
    {
        Validator v = validator_func;
        valid = v(text);
    }
    return this;
}

GuiTextEntry* GuiTextEntry::setTextSize(float size)
{
    this->text_size = size;
    return this;
}

GuiTextEntry* GuiTextEntry::callback(func_t func)
{
    this->func = func;
    return this;
}

GuiTextEntry* GuiTextEntry::enterCallback(func_t func)
{
    this->enter_func = func;
    return this;
}

GuiTextEntry* GuiTextEntry::validator(Validator v)
{
    this->validator_func = v;
    valid = v(text);
    return this;
}
