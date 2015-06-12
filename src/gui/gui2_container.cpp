#include "gui2_container.h"
#include "gui2_element.h"
#include "input.h"

GuiContainer::GuiContainer()
{
}

GuiContainer::~GuiContainer()
{
    for(GuiElement* element : elements)
    {
        element->owner = nullptr;
        delete element;
    }
}

void GuiContainer::drawElements(sf::FloatRect window_rect, sf::RenderTarget& window)
{
    sf::Vector2f mouse_position = InputHandler::getMousePos();
    for(GuiElement* element : elements)
    {
        element->updateRect(window_rect);
        element->hover = element->rect.contains(mouse_position);
    }
    
    for(GuiElement* element : elements)
    {
        if (element->visible)
        {
            element->onDraw(window);
            element->drawElements(element->rect, window);
        }
    }
}

GuiElement* GuiContainer::getClickElement(sf::Vector2f mouse_position)
{
    for(std::list<GuiElement*>::reverse_iterator it = elements.rbegin(); it != elements.rend(); it++)
    {
        GuiElement* element = *it;
        
        if (element->hover && element->visible && element->enabled)
        {
            GuiElement* clicked = element->getClickElement(mouse_position);
            if (clicked)
                return clicked;
            if (element->onMouseDown(mouse_position))
            {
                return element;
            }
        }
    }
    return nullptr;
}
