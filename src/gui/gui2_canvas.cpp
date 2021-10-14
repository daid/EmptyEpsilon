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

    drawElements(mouse_position, window_rect, renderer);

    if (enable_debug_rendering)
    {
        drawDebugElements(window_rect, renderer);
    }
}

bool GuiCanvas::onPointerMove(glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    return false;
}

void GuiCanvas::onPointerLeave(sp::io::Pointer::ID id)
{
    mouse_position = {-100, -100};
}

bool GuiCanvas::onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    click_element = getClickElement(button, position, id);
    focus(click_element);
    return click_element != nullptr;
}

void GuiCanvas::onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    if (click_element)
        click_element->onMouseDrag(position, id);
}

void GuiCanvas::onPointerUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    mouse_position = position;
    if (click_element)
    {
        click_element->onMouseUp(position, id);
        click_element = nullptr;
    }
}

void GuiCanvas::onTextInput(const string& text)
{
    if (focus_element)
        focus_element->onTextInput(text);
}

void GuiCanvas::onTextInput(sp::TextInputEvent e)
{
    if (focus_element)
        focus_element->onTextInput(e);
}

void GuiCanvas::handleKeyPress(const SDL_KeyboardEvent& key, int unicode)
{
    std::vector<HotkeyResult> hotkey_list = HotkeyConfig::get().getHotkey(key);
    for(HotkeyResult& result : hotkey_list)
    {
        forwardKeypressToElements(result);
        onHotkey(result);
    }
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

void GuiCanvas::onHotkey(const HotkeyResult& key)
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
