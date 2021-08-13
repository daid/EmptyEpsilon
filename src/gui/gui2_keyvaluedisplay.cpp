#include "textureManager.h"
#include "gui2_keyvaluedisplay.h"

GuiKeyValueDisplay::GuiKeyValueDisplay(GuiContainer* owner, const string& id, float div_distance, const string& key, const string& value)
: GuiElement(owner, id), key(key), value(value), text_size(20.f), div_distance(div_distance), color(glm::u8vec4{255,255,255,255})
{
}

void GuiKeyValueDisplay::onDraw(sp::RenderTarget& renderer)
{
    float div_size = 5.f;
    constexpr auto key_alignment = sp::Alignment::CenterRight;
    constexpr auto value_alignment = sp::Alignment::CenterLeft;

    renderer.drawStretched(rect, "gui/widget/KeyValueBackground.png", color);
    if (rect.size.x >= rect.size.y)
    {
        renderer.drawText(sp::Rect(rect.position.x, rect.position.y, rect.size.x * div_distance - div_size, rect.size.y), key, key_alignment, text_size);
        renderer.drawText(sp::Rect(rect.position.x + rect.size.x * div_distance + div_size, rect.position.y, rect.size.x * (1.f - div_distance), rect.size.y), value, value_alignment, text_size, bold_font);
        if (icon_texture != "")
        {
            renderer.drawSprite(icon_texture, glm::vec2(rect.position.x + rect.size.y * 0.5, rect.position.y + rect.size.y * 0.5), rect.size.y * 0.8);
        }
    }
    else
    {
        renderer.drawVerticalText(sp::Rect(rect.position.x, rect.position.y + rect.size.y * (1.f - div_distance) + div_size, rect.size.x, rect.size.y * div_distance - div_size), key, key_alignment, text_size);
        renderer.drawVerticalText(sp::Rect(rect.position.x, rect.position.y, rect.size.x, rect.size.y * (1.f - div_distance) - div_size), value, value_alignment, text_size, bold_font);
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

GuiKeyValueDisplay* GuiKeyValueDisplay::setColor(glm::u8vec4 color)
{
    this->color = color;
    return this;
}

GuiKeyValueDisplay* GuiKeyValueDisplay::setIcon(const string& icon_texture)
{
    this->icon_texture = icon_texture;
    return this;
}
