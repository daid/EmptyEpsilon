#include "snapSlider.h"

GuiSnapSlider::GuiSnapSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiSlider(owner, id, min_value, max_value, start_value, func), snap_value(start_value)
{
}

void GuiSnapSlider::onMouseUp(sf::Vector2f position)
{
    if (value != snap_value)
    {
        value = snap_value;
        if (func)
            func(value);
    }
}
