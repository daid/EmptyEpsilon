#include "textureManager.h"
#include "vectorUtils.h"
#include "logging.h"
#include "gui2_rotationdial.h"
#include "preferenceManager.h"

GuiRotationDial::GuiRotationDial(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), func(func)
{
}

void GuiRotationDial::onDraw(sp::RenderTarget& renderer)
{
    auto center = getCenterPoint();
    float radius = std::min(rect.size.x, rect.size.y) * 0.5f;

    renderer.drawSprite("gui/widget/dial_background.png", center, radius * 2.0f);
    renderer.drawRotatedSprite("gui/widget/dial_button.png", center, radius * 2.0f, (value - min_value) / (max_value - min_value) * 360.0f);
}

bool GuiRotationDial::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    auto center = getCenterPoint();
    float radius = std::min(rect.size.x, rect.size.y) / 2.0f;

    auto diff = position - center;
    if (glm::length(diff) > radius)
        return false;
    if (glm::length(diff) < radius * 0.875f)
        return false;

    onMouseDrag(position, id);
    return true;
}

void GuiRotationDial::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    auto center = getCenterPoint();

    auto diff = position - center;

    float new_value = (vec2ToAngle(diff) + 90.0f) / 360.0f;
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

void GuiRotationDial::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
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
