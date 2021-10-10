#ifndef GUI2_CANVAS_H
#define GUI2_CANVAS_H

#include "engine.h"
#include "gui2_container.h"

class GuiCanvas : public Renderable, public GuiContainer, public InputEventHandler, private JoystickEventHandler
{
private:
    GuiElement* click_element;
    GuiElement* focus_element;
    glm::vec2 previous_mouse_position;
    bool enable_debug_rendering;
public:
    GuiCanvas();
    virtual ~GuiCanvas();

    virtual void render(sp::RenderTarget& window) override;
    virtual bool onPointerMove(glm::vec2 position, int id) override;
    virtual void onPointerLeave(int id) override;
    virtual bool onPointerDown(sp::io::Pointer::Button button, glm::vec2 position, int id) override;
    virtual void onPointerDrag(glm::vec2 position, int id) override;
    virtual void onPointerUp(glm::vec2 position, int id) override;
    virtual void onTextInput(const string& text) override;
    virtual void onTextInput(sp::TextInputEvent e) override;

    virtual void handleKeyPress(const SDL_KeyboardEvent& key, int unicode) override;
    virtual void handleJoystickAxis(unsigned int joystickId, int axis, float position) override;
    virtual void handleJoystickButton(unsigned int joystickId, unsigned int button, bool state) override;

    virtual void onHotkey(const HotkeyResult& key);
    virtual void onKey(const SDL_KeyboardEvent& key, int unicode);

    void focus(GuiElement* element);
    //Called when an element is destroyed in this tree. Recursive tests if the given element or any of it's children currently has focus, and unsets that focus.
    void unfocusElementTree(GuiElement* element);
};

#endif//GUI2_CANVAS_H
