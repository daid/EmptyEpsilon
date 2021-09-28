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

void GuiCanvas::render(sp::RenderTarget& renderer)
{
    auto window_size = renderer.getVirtualSize();
    sp::Rect window_rect(0, 0, window_size.x, window_size.y);

    auto mouse_position = InputHandler::getMousePos();

    drawElements(window_rect, renderer);

    if (enable_debug_rendering)
    {
        drawDebugElements(window_rect, renderer);
    }

    if (InputHandler::mouseIsPressed(0) || InputHandler::mouseIsPressed(1) || InputHandler::mouseIsPressed(2))
    {
        click_element = getClickElement(mouse_position);
        if (!click_element)
            onClick(mouse_position);
        focus(click_element);
    }
    if (InputHandler::mouseIsDown(0) || InputHandler::mouseIsDown(1) || InputHandler::mouseIsDown(2))
    {
        if (previous_mouse_position != mouse_position)
            if (click_element)
                click_element->onMouseDrag(mouse_position);
    }
    if (InputHandler::mouseIsReleased(0) || InputHandler::mouseIsReleased(1) || InputHandler::mouseIsReleased(2))
    {
        if (click_element)
        {
            click_element->onMouseUp(mouse_position);
            click_element = nullptr;
        }
    }
    previous_mouse_position = mouse_position;
}

void GuiCanvas::handleKeyPress(const SDL_KeyboardEvent& key, int unicode)
{
    if (focus_element)
        if (focus_element->onKey(key, unicode))
            return;
    std::vector<HotkeyResult> hotkey_list = HotkeyConfig::get().getHotkey(key);
    for(HotkeyResult& result : hotkey_list)
    {
        forwardKeypressToElements(result);
        onHotkey(result);
    }
    onKey(key, unicode);
}

void GuiCanvas::handleJoystickAxis(unsigned int joystickId, int axis, float position){
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

void GuiCanvas::onClick(glm::vec2 mouse_position)
{
}

void GuiCanvas::onHotkey(const HotkeyResult& key)
{
}

void GuiCanvas::onKey(const SDL_KeyboardEvent& key, int unicode)
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
