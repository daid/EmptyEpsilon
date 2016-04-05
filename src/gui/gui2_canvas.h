#ifndef GUI2_CANVAS_H
#define GUI2_CANVAS_H

#include "engine.h"
#include "gui2_container.h"

class GuiCanvas : public Renderable, public GuiContainer, public InputEventHandler
{
private:
    GuiElement* click_element;
    GuiElement* focus_element;
    sf::Vector2f previous_mouse_position;
    sf::Vector2f previous_joystick_xy_position;
    float previous_joystick_z_position;
    float previous_joystick_r_position;
    bool enable_debug_rendering;
public:
    GuiCanvas();
    virtual ~GuiCanvas();

    virtual void render(sf::RenderTarget& window);
    virtual void handleKeyPress(sf::Keyboard::Key key, int unicode);
    
    virtual void onClick(sf::Vector2f mouse_position);
    virtual void onKey(sf::Keyboard::Key key, int unicode);
    
    //Called when an element is destroyed in this tree.
    void unfocusElement(GuiElement* element);
};

#endif//GUI2_CANVAS_H
