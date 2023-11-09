#include "gui2_panel.h"
#include "theme.h"


GuiPanel::GuiPanel(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    style = theme->getStyle("panel");
}

void GuiPanel::onDraw(sp::RenderTarget& renderer)
{
    const auto& s = style->get(getState());
    renderer.drawStretchedHV(rect, s.size, s.texture, s.color);
}

bool GuiPanel::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}
