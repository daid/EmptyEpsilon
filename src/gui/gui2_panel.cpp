#include "gui2_panel.h"

GuiPanel::GuiPanel(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
}

void GuiPanel::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawStretchedHV(rect, 25.0f, "gui/widget/PanelBackground.png");
}

bool GuiPanel::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, int id)
{
    return true;
}
