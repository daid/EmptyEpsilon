#include "gui2_canvas.h"
#include "gui2_element.h"

GuiCanvas::GuiCanvas()
: click_element(nullptr), focus_element(nullptr)
{
    enable_debug_rendering = false;
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
GuiCanvas::~GuiCanvas()
{
}

void GuiCanvas::render(sf::RenderTarget& window)
{
    sf::Vector2f window_size = window.getView().getSize();
    sf::FloatRect window_rect(0, 0, window_size.x, window_size.y);

    sf::Vector2f mouse_position = InputHandler::getMousePos();

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
        focus(click_element);
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
    previous_mouse_position = mouse_position;
}

void GuiCanvas::handleKeyPress(sf::Event::KeyEvent key, int unicode)
{
    if (focus_element)
        if (focus_element->onKey(key, unicode))
            return;
    std::vector<HotkeyResult> hotkey_list = hotkeys.getHotkey(key);
    for(HotkeyResult& result : hotkey_list)
    {
        forwardKeypressToElements(result);
        onHotkey(result);
    }
    onKey(key, unicode);
}

void GuiCanvas::handleJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float position){
    for(AxisAction action : joystick.getAxisAction(joystickId, axis, position)){
        forwardJoystickAxisToElements(action);
    }
}

void GuiCanvas::handleJoystickButton(unsigned int joystickId, unsigned int button, bool state){
    if (state){
        for(HotkeyResult& action : joystick.getButtonAction(joystickId, button)){
            forwardKeypressToElements(action);
            onHotkey(action);
        }
    }
}

void GuiCanvas::onClick(sf::Vector2f mouse_position)
{
}

void GuiCanvas::onHotkey(const HotkeyResult& key)
{
}

void GuiCanvas::onKey(sf::Event::KeyEvent key, int unicode)
{
}

void GuiCanvas::focus(GuiElement* element)
{
    if (element == focus_element)
        return;

    if (focus_element)
    {
        focus_element->focus = false;
        focus_element->onFocusLost();
    }
    focus_element = element;
    if (focus_element)
    {
        focus_element->focus = true;
        focus_element->onFocusGained();
    }
}

void GuiCanvas::unfocusElementTree(GuiElement* element)
{
    if (focus_element == element)
        focus_element = nullptr;
    if (click_element == element)
        click_element = nullptr;
    for(GuiElement* child : element->elements)
        unfocusElementTree(child);
}
