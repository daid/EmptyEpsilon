#include "gui2_textentry.h"
#include "input.h"

GuiTextEntry::GuiTextEntry(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30)
{
}

void GuiTextEntry::onDraw(sf::RenderTarget& window)
{
    draw9Cut(window, rect, "button_background", sf::Color(192,192,192,255));
    drawText(window, sf::FloatRect(rect.left + 16, rect.top, rect.width, rect.height), text + (focus ? "_" : ""), ACenterLeft, text_size, sf::Color::Black);
}

bool GuiTextEntry::onMouseDown(sf::Vector2f position)
{
    return true;
}

bool GuiTextEntry::onKey(sf::Keyboard::Key key, int unicode)
{
    if (key == sf::Keyboard::BackSpace && text.length() > 0)
        text = text.substr(0, -1);
    if (unicode > 31 && unicode < 128)
        text += string(char(unicode));
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
