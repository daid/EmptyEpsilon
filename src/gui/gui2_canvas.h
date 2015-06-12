#ifndef GUI2_CANVAS_H
#define GUI2_CANVAS_H

#include "engine.h"
#include "gui2_container.h"

class GuiCanvas : public Renderable, public GuiContainer, public InputEventHandler
{
private:
    GuiElement* click_element;
    GuiElement* focus_element;
public:
    GuiCanvas();
    virtual ~GuiCanvas();

    virtual void render(sf::RenderTarget& window);
    virtual void handleKeyPress(sf::Keyboard::Key key, int unicode);
    
    virtual void onClick(sf::Vector2f mouse_position);
    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

#endif//GUI2_CANVAS_H
