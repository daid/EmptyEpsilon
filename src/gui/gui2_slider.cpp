#include <math.h>

#include "gui2_slider.h"
#include "preferenceManager.h"
#include "theme.h"


GuiBasicSlider::GuiBasicSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func)
{
    front_style = theme->getStyle("slider.front");
    back_style = theme->getStyle("slider.back");
}

void GuiBasicSlider::onDraw(sp::RenderTarget& renderer)
{
    auto back = back_style->get(getState());
    auto front = front_style->get(getState());

    renderer.drawStretched(rect, back.texture, back.color);

    if (rect.size.x > rect.size.y)
    {
        float x;
        x = rect.position.x + (rect.size.x - rect.size.y) * (value - min_value) / (max_value - min_value);

        renderer.drawSprite(front.texture, glm::vec2(x + rect.size.y * 0.5f, rect.position.y + rect.size.y * 0.5f), rect.size.y, front.color);
    }else{
        float y;
        y = rect.position.y + (rect.size.y - rect.size.x) * (value - min_value) / (max_value - min_value);

        renderer.drawSprite(front.texture, glm::vec2(rect.position.x + rect.size.x * 0.5f, y + rect.size.x * 0.5f), rect.size.x, front.color);
    }
}

bool GuiBasicSlider::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    onMouseDrag(position, id);
    return true;
}

void GuiBasicSlider::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    float new_value;
    if (rect.size.x > rect.size.y)
        new_value = (position.x - rect.position.x - (rect.size.y / 2.0f)) / (rect.size.x - rect.size.y);
    else
        new_value = (position.y - rect.position.y - (rect.size.x / 2.0f)) / (rect.size.y - rect.size.x);
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
        {
            func_t f = func;
            f(value);
        }
    }
}

void GuiBasicSlider::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}

GuiBasicSlider* GuiBasicSlider::setValue(float value)
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

GuiBasicSlider* GuiBasicSlider::setRange(float min, float max)
{
    this->min_value = min;
    this->max_value = max;
    setValue(this->value);
    return this;
}

float GuiBasicSlider::getValue() const
{
    return value;
}



GuiSlider::GuiSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiBasicSlider(owner, id, min_value, max_value, start_value, func)
{
    overlay_label = nullptr;
    tick_style = theme->getStyle("slider.tick");
}

void GuiSlider::onDraw(sp::RenderTarget& renderer)
{
    auto back = back_style->get(getState());
    auto tick = tick_style->get(getState());
    auto front = front_style->get(getState());

    renderer.drawStretched(rect, back.texture, back.color);

    if (rect.size.x > rect.size.y)
    {
        float x;

        for(TSnapPoint& point : snap_points)
        {
            x = rect.position.x + (rect.size.x - rect.size.y) * (point.value - min_value) / (max_value - min_value);

            renderer.drawRotatedSprite(tick.texture, glm::vec2(x + rect.size.y * 0.5f, rect.position.y + rect.size.y * 0.5f), rect.size.y, 90, tick.color);
        }
        x = rect.position.x + (rect.size.x - rect.size.y) * (value - min_value) / (max_value - min_value);

        renderer.drawSprite(front.texture, glm::vec2(x + rect.size.y * 0.5f, rect.position.y + rect.size.y * 0.5f), rect.size.y, front.color);
    }else{
        float y;
        for(TSnapPoint& point : snap_points)
        {
            y = rect.position.y + (rect.size.y - rect.size.x) * (point.value - min_value) / (max_value - min_value);

            renderer.drawSprite(tick.texture, glm::vec2(rect.position.x + rect.size.x * 0.5f, y + rect.size.x * 0.5f), rect.size.x, tick.color);
        }
        y = rect.position.y + (rect.size.y - rect.size.x) * (value - min_value) / (max_value - min_value);

        renderer.drawSprite(front.texture, glm::vec2(rect.position.x + rect.size.x * 0.5f, y + rect.size.x * 0.5f), rect.size.x, front.color);
    }

    if (overlay_label)
    {
        overlay_label->setText(string(value, 0));
    }
}

bool GuiSlider::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    onMouseDrag(position, id);
    return true;
}

void GuiSlider::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    float new_value;
    if (rect.size.x > rect.size.y)
        new_value = (position.x - rect.position.x - (rect.size.y / 2.0f)) / (rect.size.x - rect.size.y);
    else
        new_value = (position.y - rect.position.y - (rect.size.x / 2.0f)) / (rect.size.y - rect.size.x);
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
        {
            func_t f = func;
            f(value);
        }
    }
}

void GuiSlider::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
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

GuiSlider* GuiSlider::addOverlay()
{
    if (!overlay_label)
    {
        overlay_label = new GuiLabel(this, "", "", 30);
        overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }
    return this;
}


GuiSlider2D::GuiSlider2D(GuiContainer* owner, string id, glm::vec2 min_value, glm::vec2 max_value, glm::vec2 start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func)
{
    front_style = theme->getStyle("slider.front");
    back_style = theme->getStyle("slider.back");
}

void GuiSlider2D::onDraw(sp::RenderTarget& renderer)
{
    auto back = back_style->get(getState());
    auto front = front_style->get(getState());

    renderer.drawStretchedHV(rect, back.size, back.texture, back.color);

    float x = rect.position.x + (rect.size.x - 50.0f) * (value.x - min_value.x) / (max_value.x - min_value.x);
    float y = rect.position.y + (rect.size.y - 50.0f) * (value.y - min_value.y) / (max_value.y - min_value.y);

    renderer.drawSprite(front.texture, glm::vec2(x + 25, y + 25), 50, front.color);
}

bool GuiSlider2D::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    onMouseDrag(position, id);
    return true;
}

void GuiSlider2D::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    glm::vec2 new_value;
    new_value.x = (position.x - rect.position.x - 25.0f) / (rect.size.x - 50.0f);
    new_value.y = (position.y - rect.position.y - 25.0f) / (rect.size.y - 50.0f);
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

void GuiSlider2D::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}

GuiSlider2D* GuiSlider2D::clearSnapValues()
{
    snap_points.clear();
    return this;
}

GuiSlider2D* GuiSlider2D::addSnapValue(glm::vec2 value, glm::vec2 range)
{
    snap_points.emplace_back();
    snap_points.back().value = value;
    snap_points.back().range = range;
    return this;
}

GuiSlider2D* GuiSlider2D::setValue(glm::vec2 value)
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

glm::vec2 GuiSlider2D::getValue()
{
    return value;
}
