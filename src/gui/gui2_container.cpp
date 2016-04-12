#include "gui2_container.h"
#include "gui2_element.h"
#include "gui2_canvas.h"
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

void GuiContainer::drawElements(sf::FloatRect parent_rect, sf::RenderTarget& window)
{
    sf::Vector2f mouse_position = InputHandler::getMousePos();
    for(auto it = elements.begin(); it != elements.end(); )
    {
        GuiElement* element = *it;
        if (element->destroyed)
        {
            //Find the owning cancas, as we need to remove ourselves if we are the focus or click element.
            GuiCanvas* canvas = dynamic_cast<GuiCanvas*>(element->getTopLevelContainer());
            if (canvas)
                canvas->unfocusElementTree(element);

            //Delete it from our list.
            it = elements.erase(it);
            
            // Free up the memory used by the element.
            element->owner = nullptr;
            delete element;
        }else{
            element->updateRect(parent_rect);
            element->hover = element->rect.contains(mouse_position);
            
            it++;
        }
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

void GuiContainer::drawDebugElements(sf::FloatRect parent_rect, sf::RenderTarget& window)
{
    sf::Vector2f mouse_position = InputHandler::getMousePos();
    for(GuiElement* element : elements)
    {
        if (element->visible)
        {
            sf::RectangleShape draw_rect(sf::Vector2f(element->rect.width, element->rect.height));
            draw_rect.setPosition(element->rect.left, element->rect.top);
            draw_rect.setFillColor(sf::Color(255, 255, 255, 5));
            draw_rect.setOutlineColor(sf::Color::Magenta);
            draw_rect.setOutlineThickness(2.0);
            window.draw(draw_rect);
            
            element->drawDebugElements(element->rect, window);
        }
    }
            
    for(GuiElement* element : elements)
    {
        if (element->visible)
        {
            if (element->rect.contains(mouse_position))
                element->drawText(window, sf::FloatRect(element->rect.left, element->rect.top - 20, element->rect.width, 20), element->id, ATopLeft, 20, main_font, sf::Color::Red);
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

bool GuiContainer::forwardKeypressToElements(sf::Keyboard::Key key, int unicode)
{
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            if (element->isEnabled())
                if (element->onHotkey(key, unicode))
                    return true;
            if (element->forwardKeypressToElements(key, unicode))
                return true;
        }
    }
    return false;
}

bool GuiContainer::forwardJoystickXYMoveToElements(sf::Vector2f position)
{
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            if (element->isEnabled())
                if (element->onJoystickXYMove(position))
                    return true;
            if (element->forwardJoystickXYMoveToElements(position))
                return true;
        }
    }
    return false;
}

bool GuiContainer::forwardJoystickZMoveToElements(float position)
{
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            if (element->isEnabled())
                if (element->onJoystickZMove(position))
                    return true;
            if (element->forwardJoystickZMoveToElements(position))
                return true;
        }
    }
    return false;
}

bool GuiContainer::forwardJoystickRMoveToElements(float position)
{
    for(GuiElement* element : elements)
    {
        if (element->isVisible())
        {
            if (element->isEnabled())
                if (element->onJoystickRMove(position))
                    return true;
            if (element->forwardJoystickRMoveToElements(position))
                return true;
        }
    }
    return false;
}
