#include "gui2_arrow.h"
#include "theme.h"

GuiArrow::GuiArrow(GuiContainer* owner, string id, float angle)
: GuiElement(owner, id)
{
    arrow_style = theme->getStyle("arrow");
}

void GuiArrow::onDraw(sp::RenderTarget& renderer)
{
    const auto& arrow = arrow_style->get(getState());
    renderer.drawRotatedSprite(arrow.texture, getCenterPoint(), std::min(rect.size.x, rect.size.y), angle, color);
}
