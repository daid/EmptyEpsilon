#include "textureManager.h"
#include "gui2_keyvaluedisplay.h"

GuiKeyValueDisplay::GuiKeyValueDisplay(GuiContainer* owner, const string& id, float div_distance, const string& key, const string& value)
: GuiElement(owner, id), key(key), value(value), text_size(20.f), div_distance(div_distance), color(sf::Color::White)
{
}

void GuiKeyValueDisplay::onDraw(sf::RenderTarget& window)
{
    float div_size = 5.f;
    constexpr auto key_alignment = ACenterRight;
    constexpr auto value_alignment = ACenterLeft;

    drawStretched(window, rect, "gui/KeyValueBackground", color);
    if (rect.width >= rect.height)
    {
        drawText(window, sf::FloatRect(rect.left, rect.top, rect.width * div_distance - div_size, rect.height), key, key_alignment, text_size);
        drawText(window, sf::FloatRect(rect.left + rect.width * div_distance + div_size, rect.top, rect.width * (1.f - div_distance), rect.height), value, value_alignment, text_size, bold_font);
        if (icon_texture != "")
        {
            sf::Sprite icon;
            textureManager.setTexture(icon, icon_texture);
            float scale = rect.height / icon.getTextureRect().height * 0.8f;
            icon.setScale(scale, scale);
            icon.setPosition(rect.left + rect.height / 2, rect.top + rect.height / 2);
            window.draw(icon);
        }
    }
    else
    {
        drawVerticalText(window, sf::FloatRect(rect.left, rect.top + rect.height * (1.f - div_distance) + div_size, rect.width, rect.height * div_distance - div_size), key, key_alignment, text_size);
        drawVerticalText(window, sf::FloatRect(rect.left, rect.top, rect.width, rect.height * (1.f - div_distance) - div_size), value, value_alignment, text_size, bold_font);
    }
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setKey(const string& key)
{
    this->key = key;
    return this;
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setValue(const string& value)
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

GuiKeyValueDisplay* GuiKeyValueDisplay::setIcon(const string& icon_texture)
{
    this->icon_texture = icon_texture;
    return this;
}
