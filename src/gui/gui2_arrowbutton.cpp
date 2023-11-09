#include "gui2_arrowbutton.h"
#include "theme.h"


GuiArrowButton::GuiArrowButton(GuiContainer* owner, string id, float angle, func_t func)
: GuiButton(owner, id, "", func), angle(angle)
{
    front_style = theme->getStyle("button.arrow");
}

void GuiArrowButton::onDraw(sp::RenderTarget& renderer)
{
    const auto& front = front_style->get(getState());
    renderer.drawRotatedSprite(front.texture, getCenterPoint(), std::min(rect.size.x, rect.size.y), angle, front.color);
}
