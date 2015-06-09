#ifndef GUI2_CANVAS_H
#define GUI2_CANVAS_H

#include "engine.h"
#include "gui2_container.h"

class GuiCanvas : public Renderable, public GuiContainer
{
private:
    GuiElement* click_element;
public:
    GuiCanvas();
    virtual ~GuiCanvas();

    virtual void render(sf::RenderTarget& window);
};

#endif//GUI2_CANVAS_H
