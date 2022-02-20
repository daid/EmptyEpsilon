#include "gui2_progressbar.h"
#include "theme.h"


GuiProgressbar::GuiProgressbar(GuiContainer* owner, string id, float min_value, float max_value, float start_value)
: GuiElement(owner, id), min_value(min_value), max_value(max_value), value(start_value), color(glm::u8vec4(255, 255, 255, 64)), drawBackground(true)
{
    back_style = theme->getStyle("progressbar.back");
    front_style = theme->getStyle("progressbar.front");
}

void GuiProgressbar::onDraw(sp::RenderTarget& renderer)
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
        if (max_value < min_value)
            fill_rect.position.x = rect.position.x + rect.size.x - fill_rect.size.x;
        renderer.drawStretchedHVClipped(rect, fill_rect, front.size, front.texture, color);
    }
    else
    {
        fill_rect.size.y *= f;
        fill_rect.position.y = rect.position.y + rect.size.y - fill_rect.size.y;
        renderer.drawStretchedHVClipped(rect, fill_rect, front.size, front.texture, color);
    }
    renderer.drawText(rect, text, sp::Alignment::Center);
}

GuiProgressbar* GuiProgressbar::setValue(float value)
{
    this->value = value;
    return this;
}

GuiProgressbar* GuiProgressbar::setRange(float min_value, float max_value)
{
    this->min_value = min_value;
    this->max_value = max_value;
    return this;
}

GuiProgressbar* GuiProgressbar::setText(string text)
{
    this->text = text;
    return this;
}

GuiProgressbar* GuiProgressbar::setColor(glm::u8vec4 color)
{
    this->color = color;
    return this;
}

GuiProgressbar* GuiProgressbar::setDrawBackground(bool drawBackground)
{
    this->drawBackground = drawBackground;
    return this;
}
