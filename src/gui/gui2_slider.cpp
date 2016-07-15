#include <math.h>

#include "gui2_slider.h"
#include "preferenceManager.h"

GuiSlider::GuiSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func)
{
    overlay_label = nullptr;
}

void GuiSlider::onDraw(sf::RenderTarget& window)
{
    drawStretched(window, rect, "gui/SliderBackground", selectColor(colorConfig.slider.background));

    sf::Color color = selectColor(colorConfig.slider.forground);

    if (rect.width > rect.height)
    {
        float x;

        for(TSnapPoint& point : snap_points)
        {
            x = rect.left + (rect.width - rect.height) * (point.value - min_value) / (max_value - min_value);

            sf::Sprite snap_sprite;
            textureManager.setTexture(snap_sprite, "gui/SliderTick");
            snap_sprite.setRotation(90);
            snap_sprite.setPosition(x + rect.height / 2, rect.top + rect.height / 2);
            snap_sprite.setScale(rect.height / snap_sprite.getTextureRect().width, rect.height / snap_sprite.getTextureRect().width);
            snap_sprite.setColor(selectColor(colorConfig.slider.background));
            window.draw(snap_sprite);
        }
        x = rect.left + (rect.width - rect.height) * (value - min_value) / (max_value - min_value);

        sf::Sprite sprite;
        textureManager.setTexture(sprite, "gui/SliderKnob");
        sprite.setOrigin(0, 0);
        sprite.setPosition(x, rect.top);
        sprite.setScale(rect.height / sprite.getTextureRect().width, rect.height / sprite.getTextureRect().width);
        sprite.setColor(color);
        window.draw(sprite);
    }else{
        float y;
        for(TSnapPoint& point : snap_points)
        {
            y = rect.top + (rect.height - rect.width) * (point.value - min_value) / (max_value - min_value);

            sf::Sprite snap_sprite;
            textureManager.setTexture(snap_sprite, "gui/SliderTick");
            snap_sprite.setOrigin(0, 0);
            snap_sprite.setPosition(rect.left, y);
            snap_sprite.setScale(rect.width / snap_sprite.getTextureRect().width, rect.width / snap_sprite.getTextureRect().width);
            snap_sprite.setColor(selectColor(colorConfig.slider.background));
            window.draw(snap_sprite);
        }
        y = rect.top + (rect.height - rect.width) * (value - min_value) / (max_value - min_value);

        sf::Sprite sprite;
        textureManager.setTexture(sprite, "gui/SliderKnob");
        sprite.setOrigin(0, 0);
        sprite.setPosition(rect.left, y);
        sprite.setScale(rect.width / sprite.getTextureRect().width, rect.width / sprite.getTextureRect().width);
        sprite.setColor(color);
        window.draw(sprite);
    }
    
    if (overlay_label)
    {
        overlay_label->setText(string(value, 0));
    }
}

bool GuiSlider::onMouseDown(sf::Vector2f position)
{
    onMouseDrag(position);
    return true;
}

void GuiSlider::onMouseDrag(sf::Vector2f position)
{
    float new_value;
    if (rect.width > rect.height)
        new_value = (position.x - rect.left - (rect.height / 2.0)) / (rect.width - rect.height);
    else
        new_value = (position.y - rect.top - (rect.width / 2.0)) / (rect.height - rect.width);
    new_value = min_value + (max_value - min_value) * new_value;
    for(TSnapPoint& point : snap_points)
    {
        if (fabs(new_value - point.value) < point.range)
            new_value = point.value;
    }
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

void GuiSlider::onMouseUp(sf::Vector2f position)
{
}

GuiSlider* GuiSlider::clearSnapValues()
{
    snap_points.clear();
    return this;
}

GuiSlider* GuiSlider::addSnapValue(float value, float range)
{
    snap_points.emplace_back();
    snap_points.back().value = value;
    snap_points.back().range = range;
    return this;
}

GuiSlider* GuiSlider::setValue(float value)
{
    if (min_value < max_value)
    {
        if (value < min_value)
            value = min_value;
        if (value > max_value)
            value = max_value;
    }else{
        if (value > min_value)
            value = min_value;
        if (value < max_value)
            value = max_value;
    }
    this->value = value;
    return this;
}

GuiSlider* GuiSlider::setRange(float min, float max)
{
    this->min_value = min;
    this->max_value = max;
    setValue(this->value);
    return this;
}

GuiSlider* GuiSlider::addOverlay()
{
    if (!overlay_label)
    {
        overlay_label = new GuiLabel(this, "", "", 30);
        overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    return this;
}

float GuiSlider::getValue()
{
    return value;
}

GuiSlider2D::GuiSlider2D(GuiContainer* owner, string id, sf::Vector2f min_value, sf::Vector2f max_value, sf::Vector2f start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func)
{
}

void GuiSlider2D::onDraw(sf::RenderTarget& window)
{
    drawStretchedHV(window, rect, 25.0f, "gui/SliderBackground", selectColor(colorConfig.slider.background));

    sf::Color color = selectColor(colorConfig.slider.forground);

    float x = rect.left + (rect.width - 50.0) * (value.x - min_value.x) / (max_value.x - min_value.x);
    float y = rect.top + (rect.height - 50.0) * (value.y - min_value.y) / (max_value.y - min_value.y);

    sf::Sprite sprite;
    textureManager.setTexture(sprite, "gui/SliderKnob");
    sprite.setOrigin(0, 0);
    sprite.setPosition(x, y);
    sprite.setScale(50.0 / sprite.getTextureRect().width, 50.0 / sprite.getTextureRect().width);
    sprite.setColor(color);
    window.draw(sprite);
}

bool GuiSlider2D::onMouseDown(sf::Vector2f position)
{
    onMouseDrag(position);
    return true;
}

void GuiSlider2D::onMouseDrag(sf::Vector2f position)
{
    sf::Vector2f new_value;
    new_value.x = (position.x - rect.left - 25.0f) / (rect.width - 50.0f);
    new_value.y = (position.y - rect.top - 25.0f) / (rect.height - 50.0f);
    new_value.x = min_value.x + (max_value.x - min_value.x) * new_value.x;
    new_value.y = min_value.y + (max_value.y - min_value.y) * new_value.y;
    for(TSnapPoint& point : snap_points)
    {
        if (fabs(new_value.x - point.value.x) < point.range.x && fabs(new_value.y - point.value.y) < point.range.y)
            new_value = point.value;
    }
    if (min_value.x < max_value.x)
    {
        if (new_value.x < min_value.x)
            new_value.x = min_value.x;
        if (new_value.x > max_value.x)
            new_value.x = max_value.x;
    }else{
        if (new_value.x > min_value.x)
            new_value.x = min_value.x;
        if (new_value.x < max_value.x)
            new_value.x = max_value.x;
    }
    if (min_value.y < max_value.y)
    {
        if (new_value.y < min_value.y)
            new_value.y = min_value.y;
        if (new_value.y > max_value.y)
            new_value.y = max_value.y;
    }else{
        if (new_value.y > min_value.y)
            new_value.y = min_value.y;
        if (new_value.y < max_value.y)
            new_value.y = max_value.y;
    }
    if (value != new_value)
    {
        value = new_value;
        if (func)
            func(value);
    }
}

void GuiSlider2D::onMouseUp(sf::Vector2f position)
{
}

GuiSlider2D* GuiSlider2D::clearSnapValues()
{
    snap_points.clear();
    return this;
}

GuiSlider2D* GuiSlider2D::addSnapValue(sf::Vector2f value, sf::Vector2f range)
{
    snap_points.emplace_back();
    snap_points.back().value = value;
    snap_points.back().range = range;
    return this;
}

GuiSlider2D* GuiSlider2D::setValue(sf::Vector2f value)
{
    if (min_value.x < max_value.x)
    {
        if (value.x < min_value.x)
            value.x = min_value.x;
        if (value.x > max_value.x)
            value.x = max_value.x;
    }else{
        if (value.x > min_value.x)
            value.x = min_value.x;
        if (value.x < max_value.x)
            value.x = max_value.x;
    }
    if (min_value.y < max_value.y)
    {
        if (value.y < min_value.y)
            value.y = min_value.y;
        if (value.y > max_value.y)
            value.y = max_value.y;
    }else{
        if (value.y > min_value.y)
            value.y = min_value.y;
        if (value.y < max_value.y)
            value.y = max_value.y;
    }
    this->value = value;
    return this;
}

sf::Vector2f GuiSlider2D::getValue()
{
    return value;
}
