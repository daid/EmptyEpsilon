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
    case LayoutHorizontalRows:
        {
            int count = 0;
            for(GuiElement* element : elements)
            {
                if (!element->isDestroyed() && element->isVisible())
                    count += 1;
            }
            for(GuiElement* element : elements)
            {
                if (!element->isDestroyed() && element->isVisible())
                {
                    element->setSize(GuiElement::GuiSizeMax, parent_rect.height / count);
                    element->setPosition(offset.x, offset.y);
                    offset.y += parent_rect.height / count;
                }
            }
        }
        GuiContainer::drawElements(parent_rect, window);
        return;
    case LayoutVerticalColumns:
        {
            int count = 0;
            for(GuiElement* element : elements)
            {
                if (!element->isDestroyed() && element->isVisible())
                    count += 1;
            }
            for(GuiElement* element : elements)
            {
                if (!element->isDestroyed() && element->isVisible())
                {
                    element->setSize(parent_rect.width / count, GuiElement::GuiSizeMax);
                    element->setPosition(offset.x, offset.y);
                    offset.x += parent_rect.width / count;
                }
            }
        }
        GuiContainer::drawElements(parent_rect, window);
        return;
    }
    for(GuiElement* element : elements)
    {
        if (!element->isDestroyed() && element->isVisible())
        {
            element->setPosition(offset, alignment);
            offset.x += element->getSize().x * scale.x;
            offset.y += element->getSize().y * scale.y;
        }
    }
    GuiContainer::drawElements(parent_rect, window);
}
