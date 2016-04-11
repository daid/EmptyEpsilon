#include "gui2_autolayout.h"

GuiAutoLayout::GuiAutoLayout(GuiContainer* owner, string id, ELayoutMode mode)
: GuiElement(owner, id), mode(mode)
{
}

void GuiAutoLayout::onDraw(sf::RenderTarget& window)
{
}

void GuiAutoLayout::drawElements(sf::FloatRect parent_rect, sf::RenderTarget& window)
{
    sf::Vector2f offset(0, 0);
    sf::Vector2f scale(0, 0);
    EGuiAlign alignment = ACenterLeft;
    switch(mode)
    {
    case LayoutHorizontalLeftToRight:
        alignment = ACenterLeft;
        scale.x = 1.0;
        break;
    case LayoutHorizontalRightToLeft:
        alignment = ACenterRight;
        scale.x = -1.0;
        break;
    case LayoutVerticalTopToBottom:
        alignment = ATopCenter;
        scale.y = 1.0;
        break;
    case LayoutVerticalBottomToTop:
        alignment = ABottomCenter;
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
    GuiContainer::drawElements(parent_rect, window);
}
