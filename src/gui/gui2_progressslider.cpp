#include "gui2_progressslider.h"
#include "theme.h"


GuiProgressSlider::GuiProgressSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiProgressbar(owner, id, min_value, max_value, start_value), callback(func)
{
}

bool GuiProgressSlider::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    onMouseDrag(position, id);
    return true;
}

void GuiProgressSlider::onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    float new_value;
    if (rect.size.x > rect.size.y)
        new_value = (position.x - rect.position.x) / (rect.size.x);
    else
        new_value = (position.y - rect.position.y) / (rect.size.y);
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
        if (callback)
        {
            func_t f = callback;
            f(value);
        }
    }
}

void GuiProgressSlider::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}
