#include "textureManager.h"
#include "gui2_keyvaluedisplay.h"

GuiKeyValueDisplay::GuiKeyValueDisplay(GuiContainer* owner, string id, float div_distance, string key, string value)
: GuiElement(owner, id), div_distance(div_distance), key(key), value(value), text_size(20), color(sf::Color::White)
{
}

void GuiKeyValueDisplay::onDraw(sf::RenderTarget& window)
{
    float div_size = 5.0;
    
    drawStretched(window, rect, "gui/KeyValueBackground", color);
    if (rect.width >= rect.height)
    {
        drawText(window, sf::FloatRect(rect.left, rect.top, rect.width * div_distance - div_size, rect.height), key, ACenterRight, text_size);
        drawText(window, sf::FloatRect(rect.left + rect.width * div_distance + div_size, rect.top, rect.width * (1.0 - div_distance), rect.height), value, ACenterLeft, text_size, bold_font);
        if (icon_texture != "")
        {
            sf::Sprite icon;
            textureManager.setTexture(icon, icon_texture);
            icon.setScale(rect.height / icon.getTextureRect().height, rect.height / icon.getTextureRect().height);
            icon.setPosition(rect.left + rect.height / 2, rect.top + rect.height / 2);
            window.draw(icon);
        }
    }
    else
    {
        drawVerticalText(window, sf::FloatRect(rect.left, rect.top + rect.height * (1.0 - div_distance) + div_size, rect.width, rect.height * div_distance - div_size), key, ACenterRight, text_size);
        drawVerticalText(window, sf::FloatRect(rect.left, rect.top, rect.width, rect.height * (1.0 - div_distance) - div_size), value, ACenterLeft, text_size, bold_font);
    }
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setKey(string key)
{
    this->key = key;
    return this;
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setValue(string value)
{
    this->value = value;
    return this;
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setTextSize(float text_size)
{
    this->text_size = text_size;
    return this;
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setColor(sf::Color color)
{
    this->color = color;
    return this;
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setIcon(string icon_texture)
{
    this->icon_texture = icon_texture;
    return this;
}
