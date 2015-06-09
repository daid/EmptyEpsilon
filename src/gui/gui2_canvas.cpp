#include "gui2_canvas.h"
#include "gui2_element.h"

GuiCanvas::GuiCanvas()
: click_element(nullptr)
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

    if (InputHandler::mouseIsPressed(sf::Mouse::Left))
    {
        click_element = getClickElement(mouse_position);
    }
    if (InputHandler::mouseIsDown(sf::Mouse::Left))
    {
        if (click_element)
            click_element->onMouseDrag(mouse_position);
    }
    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        if (click_element)
        {
            click_element->onMouseUp(mouse_position);
            click_element = nullptr;
        }
    }
}
