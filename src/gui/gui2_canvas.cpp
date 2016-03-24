#include "gui2_canvas.h"
#include "gui2_element.h"

GuiCanvas::GuiCanvas()
: click_element(nullptr), focus_element(nullptr)
{
    previous_joystick_z_position = 0;
    previous_joystick_r_position = 0;
    enable_debug_rendering = false;
}

GuiCanvas::~GuiCanvas()
{
}

void GuiCanvas::render(sf::RenderTarget& window)
{
    sf::Vector2f window_size = window.getView().getSize();
    sf::FloatRect window_rect(0, 0, window_size.x, window_size.y);
    
    sf::Vector2f mouse_position = InputHandler::getMousePos();
    sf::Vector2f joystick_xy_position = InputHandler::getJoysticXYPos();
    float joystick_z_position = InputHandler::getJoysticZPos();
    float joystick_r_position = InputHandler::getJoysticRPos();
    
    drawElements(window_rect, window);
    
    if (enable_debug_rendering)
    {
        drawDebugElements(window_rect, window);
    }

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
        if (previous_mouse_position != mouse_position)
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
    
    if (joystick_xy_position != previous_joystick_xy_position)
        forwardJoystickXYMoveToElements(joystick_xy_position);
        
    if (joystick_z_position != previous_joystick_z_position)
        forwardJoystickZMoveToElements(joystick_z_position);
        
    if (joystick_r_position != previous_joystick_r_position)
        forwardJoystickRMoveToElements(joystick_r_position);
    
    previous_joystick_xy_position = joystick_xy_position;
    previous_joystick_z_position = joystick_z_position;
    previous_joystick_r_position = joystick_r_position;
    previous_mouse_position = mouse_position;
}

void GuiCanvas::handleKeyPress(sf::Keyboard::Key key, int unicode)
{
    if (focus_element)
        if (focus_element->onKey(key, unicode))
            return;
    if (forwardKeypressToElements(key, unicode))
        return;
    onKey(key, unicode);
}

void GuiCanvas::onClick(sf::Vector2f mouse_position)
{
}

void GuiCanvas::onKey(sf::Keyboard::Key key, int unicode)
{
}
