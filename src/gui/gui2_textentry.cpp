#include "gui2_textentry.h"
#include "input.h"

GuiTextEntry::GuiTextEntry(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30)
{
}

void GuiTextEntry::onDraw(sf::RenderTarget& window)
{
    draw9Cut(window, rect, "button_background", sf::Color(192,192,192,255));
    drawText(window, sf::FloatRect(rect.left + 16, rect.top, rect.width, rect.height), text + "_", ACenterLeft, text_size, sf::Color::Black);

    if (InputHandler::keyboardIsPressed(sf::Keyboard::BackSpace) && text.length() > 0)
        text = text.substr(0, -1);
    text += InputHandler::getKeyboarddrawTextEntry();
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
