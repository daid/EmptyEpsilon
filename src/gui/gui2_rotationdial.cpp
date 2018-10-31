#include "textureManager.h"
#include "vectorUtils.h"
#include "logging.h"
#include "gui2_rotationdial.h"
#include "preferenceManager.h"

GuiRotationDial::GuiRotationDial(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func)
{
}

void GuiRotationDial::onDraw(sf::RenderTarget& window)
{
    sf::Vector2f center = getCenterPoint();
    float radius = std::min(rect.width, rect.height) / 2.0f;
    
    sf::Sprite sprite;
    textureManager.setTexture(sprite, "dial_background.png");
    sprite.setPosition(center);
    sprite.setScale(radius * 2 / sprite.getTextureRect().height, radius * 2 / sprite.getTextureRect().height);
    window.draw(sprite);

    textureManager.setTexture(sprite, "dial_button.png");
    sprite.setPosition(center);
    sprite.setScale(radius * 2 / sprite.getTextureRect().height, radius * 2 / sprite.getTextureRect().height);
    sprite.setRotation((value - min_value) / (max_value - min_value) * 360.0f);
    window.draw(sprite);
}

bool GuiRotationDial::onMouseDown(sf::Vector2f position)
{
    sf::Vector2f center = getCenterPoint();
    float radius = std::min(rect.width, rect.height) / 2.0f;
    
    sf::Vector2f diff = position - center;
    if (diff > radius)
        return false;
    if (diff < radius * 0.875f)
        return false;
    
    onMouseDrag(position);
    return true;
}

void GuiRotationDial::onMouseDrag(sf::Vector2f position)
{
    sf::Vector2f center = getCenterPoint();
    
    sf::Vector2f diff = position - center;

    float new_value = (sf::vector2ToAngle(diff) + 90.0f) / 360.0f;
    if (new_value < 0.0f)
        new_value += 1.0f;
    new_value = min_value + (max_value - min_value) * new_value;
    if (min_value < max_value)
    {
        if (new_value < min_value)
            new_value = min_value;
        if (new_value > max_value)
            new_value = max_value;
    }else{
        if (new_value > min_value)
            new_value = min_value;
        if (new_value < max_value)
            new_value = max_value;
    }
    if (value != new_value)
    {
        value = new_value;
        if (func)
            func(value);
    }
}

void GuiRotationDial::onMouseUp(sf::Vector2f position)
{
}

GuiRotationDial* GuiRotationDial::setValue(float value)
{
    if (min_value < max_value)
    {
        while(value < min_value)
            value += (max_value - min_value);
        while(value > max_value)
            value -= (max_value - min_value);
    }else{
        while(value < max_value)
            value += (min_value - max_value);
        while(value > min_value)
            value -= (min_value - max_value);
    }
    this->value = value;
    return this;
}

float GuiRotationDial::getValue() const
{
    return value;
}
