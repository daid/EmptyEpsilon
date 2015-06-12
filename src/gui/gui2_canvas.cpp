#include "gui2_canvas.h"
#include "gui2_element.h"

GuiCanvas::GuiCanvas()
: click_element(nullptr), focus_element(nullptr)
{
}

GuiCanvas::~GuiCanvas()
{
}

void GuiCanvas::render(sf::RenderTarget& window)
{
    sf::Vector2f window_size = window.getView().getSize();
    sf::FloatRect window_rect(0, 0, window_size.x, window_size.y);
    
    sf::Vector2f mouse_position = InputHandler::getMousePos();
    
    drawElements(window_rect, window);

    if (InputHandler::mouseIsPressed(sf::Mouse::Left) || InputHandler::mouseIsPressed(sf::Mouse::Right) || InputHandler::mouseIsPressed(sf::Mouse::Middle))
    {
        click_element = getClickElement(mouse_position);
        if (!click_element)
            onClick(mouse_position);
        if (focus_element)
            focus_element->focus = false;
        focus_element = click_element;
        if (focus_element)
            focus_element->focus = true;
    }
    if (InputHandler::mouseIsDown(sf::Mouse::Left) || InputHandler::mouseIsDown(sf::Mouse::Right) || InputHandler::mouseIsDown(sf::Mouse::Middle))
    {
        if (click_element)
            click_element->onMouseDrag(mouse_position);
    }
    if (InputHandler::mouseIsReleased(sf::Mouse::Left) || InputHandler::mouseIsReleased(sf::Mouse::Right) || InputHandler::mouseIsReleased(sf::Mouse::Middle))
    {
        if (click_element)
        {
            click_element->onMouseUp(mouse_position);
            click_element = nullptr;
        }
    }
}

void GuiCanvas::handleKeyPress(sf::Keyboard::Key key, int unicode)
{
    if (focus_element)
        if (focus_element->onKey(key, unicode))
            return;
    onKey(key, unicode);
}

void GuiCanvas::onClick(sf::Vector2f mouse_position)
{
}

void GuiCanvas::onKey(sf::Keyboard::Key key, int unicode)
{
}
