#include "gui2_box.h"

GuiBox::GuiBox(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
}

void GuiBox::onDraw(sf::RenderTarget& window)
{
    draw9Cut(window, rect, "border_background", sf::Color::White);
}
