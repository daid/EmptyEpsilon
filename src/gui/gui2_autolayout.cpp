#include "gui2_autolayout.h"

GuiAutoLayout::GuiAutoLayout(GuiContainer* owner, string id, ELayoutMode mode)
: GuiElement(owner, id), mode(mode)
{
}

void GuiAutoLayout::onDraw(sf::RenderTarget& window)
{
}

void GuiAutoLayout::drawElements(sf::FloatRect window_rect, sf::RenderTarget& window)
{
    sf::Vector2f offset(0, 0);
    sf::Vector2f scale(0, 0);
    EGuiAlign alignment;
    switch(mode)
    {
    case LayoutHorizontalLeftToRight:
        alignment = ATopLeft;
        scale.x = 1.0;
        break;
    case LayoutHorizontalRightToLeft:
        alignment = ATopRight;
        scale.x = -1.0;
        break;
    case LayoutVerticalTopToBottom:
        alignment = ATopLeft;
        scale.y = 1.0;
        break;
    case LayoutVerticalBottomToTop:
        alignment = ABottomLeft;
        scale.y = -1.0;
        break;
    }
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            element->setPosition(offset, alignment);
            offset.x += element->getSize().x * scale.x;
            offset.y += element->getSize().y * scale.y;
        }
    }
    GuiContainer::drawElements(window_rect, window);
}
