#include "snapSlider.h"

GuiSnapSlider::GuiSnapSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiSlider(owner, id, min_value, max_value, start_value, func), snap_value(start_value)
{
}

void GuiSnapSlider::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (value != snap_value)
    {
        value = snap_value;
        if (func)
            func(value);
    }
}

GuiSnapSlider2D::GuiSnapSlider2D(GuiContainer* owner, string id, glm::vec2 min_value, glm::vec2 max_value, glm::vec2 start_value, func_t func)
: GuiSlider2D(owner, id, min_value, max_value, start_value, func), snap_value(start_value)
{
}

void GuiSnapSlider2D::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    if (value != snap_value)
    {
        value = snap_value;
        if (func)
            func(value);
    }
}
