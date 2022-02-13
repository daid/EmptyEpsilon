#include "gui2_autolayout.h"

GuiAutoLayout::GuiAutoLayout(GuiContainer* owner, string id, ELayoutMode mode)
: GuiElement(owner, id), mode(mode)
{
}

void GuiAutoLayout::onDraw(sp::RenderTarget& target)
{
}

void GuiAutoLayout::drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& renderer)
{
    glm::vec2 offset(0, 0);
    glm::vec2 scale(0, 0);
    sp::Alignment alignment = sp::Alignment::CenterLeft;
    switch(mode)
    {
    case LayoutVerticalColumns:
        {
            int count = 0;
            for(GuiElement* element : children)
            {
                if (!element->isDestroyed() && element->isVisible())
                    count += 1;
            }
            for(GuiElement* element : children)
            {
                if (!element->isDestroyed() && element->isVisible())
                {
                    element->setSize(parent_rect.size.x / count, GuiElement::GuiSizeMax);
                    element->setPosition(offset.x, offset.y);
                    offset.x += parent_rect.size.x / count;
                }
            }
        }
        GuiContainer::drawElements(mouse_position, parent_rect, renderer);
        return;
    }
    for(GuiElement* element : children)
    {
        if (!element->isDestroyed() && element->isVisible())
        {
            element->setPosition(offset, alignment);
            offset.x += element->getSize().x * scale.x;
            offset.y += element->getSize().y * scale.y;
        }
    }
    GuiContainer::drawElements(mouse_position, parent_rect, renderer);
}
