#ifndef GUI2_CANVAS_H
#define GUI2_CANVAS_H

#include "engine.h"
#include "gui2_container.h"

class GuiCanvas : public Renderable, public GuiContainer, public InputEventHandler, private JoystickEventHandler
{
private:
    GuiElement* click_element;
    GuiElement* focus_element;
    sf::Vector2f previous_mouse_position;
    bool enable_debug_rendering;
public:
    GuiCanvas();
    virtual ~GuiCanvas() = default;

    virtual void render(sf::RenderTarget& window) override;
    virtual void handleKeyPress(sf::Event::KeyEvent key, int unicode) override;
    virtual void handleJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float position) override;
    virtual void handleJoystickButton(unsigned int joystickId, unsigned int button, bool state) override;

    virtual void onClick(sf::Vector2f mouse_position);
    virtual void onHotkey(const HotkeyResult& key);
    virtual void onKey(sf::Event::KeyEvent key, int unicode);

    void focus(GuiElement* element);
    //Called when an element is destroyed in this tree. Recursive tests if the given element or any of it's children currently has focus, and unsets that focus.
    void unfocusElementTree(GuiElement* element);
};

#endif//GUI2_CANVAS_H
