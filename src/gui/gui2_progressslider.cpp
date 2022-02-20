#include "gui2_progressslider.h"
#include "theme.h"


GuiProgressSlider::GuiProgressSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func)
: GuiBasicSlider(owner, id, min_value, max_value, start_value, func), color(glm::u8vec4(255, 255, 255, 64)), drawBackground(true)
{
    back_style = theme->getStyle("progressbar.back");
    front_style = theme->getStyle("progressbar.front");
}

void GuiProgressSlider::onDraw(sp::RenderTarget& renderer)
{
    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    float f = (value - min_value) / (max_value - min_value);

    if (drawBackground)
        renderer.drawStretched(rect, back.texture, back.color);

    sp::Rect fill_rect = rect;
    if (rect.size.x >= rect.size.y)
    {
        fill_rect.size.x *= f;
    }
    else
    {
        fill_rect.size.y *= f;
        fill_rect.position.y = rect.position.y + rect.size.y - fill_rect.size.y;
    }
    renderer.drawStretchedHVClipped(rect, fill_rect, front.size, front.texture, color);
    renderer.drawText(rect, text, sp::Alignment::Center);
}

GuiProgressSlider* GuiProgressSlider::setText(string text)
{
    this->text = text;
    return this;
}

GuiProgressSlider* GuiProgressSlider::setColor(glm::u8vec4 color)
{
    this->color = color;
    return this;
}

GuiProgressSlider* GuiProgressSlider::setDrawBackground(bool drawBackground)
{
    this->drawBackground = drawBackground;
    return this;
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
        new_value = (position.x - rect.position.x+2) / (rect.size.x-4);
    else
        new_value = (position.y - rect.position.y+2) / (rect.size.y-4);
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

void GuiProgressSlider::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}
