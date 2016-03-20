#include "gui2_panel.h"

GuiPanel::GuiPanel(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
}

void GuiPanel::onDraw(sf::RenderTarget& window)
{
    drawStretchedHV(window, rect, "gui/PanelBackground");
}

bool GuiPanel::onMouseDown(sf::Vector2f position)
{
    return true;
}
