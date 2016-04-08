#include "gui2_textentry.h"
#include "input.h"

GuiTextEntry::GuiTextEntry(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30), func(nullptr)
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

bool GuiTextEntry::onKey(sf::Keyboard::Key key, int unicode)
{
    if (key == sf::Keyboard::BackSpace && text.length() > 0)
    {
        text = text.substr(0, -1);
        if (func)
            func(text);
    }
    if (key == sf::Keyboard::Return)
    {
        if (enter_func)
            enter_func(text);
    }
    if (unicode > 31 && unicode < 128)
    {
        text += string(char(unicode));
        if (func)
            func(text);
    }
    return true;
}

string GuiTextEntry::getText()
{
    return text;
}

GuiTextEntry* GuiTextEntry::setText(string text)
{
    this->text = text;
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
