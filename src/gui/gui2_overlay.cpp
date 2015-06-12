#include "gui2_overlay.h"

GuiOverlay::GuiOverlay(GuiContainer* owner, string id, sf::Color color)
: GuiElement(owner, id), color(color)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiOverlay::onDraw(sf::RenderTarget& window)
{
    if (color.a > 0)
    {
        sf::RectangleShape overlay(sf::Vector2f(rect.width, rect.height));
        overlay.setPosition(rect.left, rect.top);
        overlay.setFillColor(color);
        window.draw(overlay);
    }
}

GuiOverlay* GuiOverlay::setColor(sf::Color color)
{
    this->color = color;
    return this;
}

GuiOverlay* GuiOverlay::setAlpha(int alpha)
{
    color.a = std::max(0, std::min(255, alpha));
    return this;
}
