#include "gui2_arrow.h"

GuiArrow::GuiArrow(GuiContainer* owner, string id, float angle)
: GuiElement(owner, id), color(glm::u8vec4{255,255,255,255}), angle(angle)
{
}

void GuiArrow::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawRotatedSprite("gui/widget/IndicatorArrow.png", getCenterPoint(), std::min(rect.size.x, rect.size.y), angle, color);
}
