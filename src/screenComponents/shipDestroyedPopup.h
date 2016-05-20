#ifndef GUI_SHIP_DESTROYED_RETURN_TIMEOUT_H
#define GUI_SHIP_DESTROYED_RETURN_TIMEOUT_H

#include "gui/gui2_element.h"

class GuiPanel;
class GuiCanvas;

class GuiShipDestroyedPopup : public GuiElement
{
private:
    GuiPanel* frame;
    GuiCanvas* owner;
    sf::Clock show_timeout;
public:
    GuiShipDestroyedPopup(GuiCanvas* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SHIP_DESTROYED_RETURN_TIMEOUT_H
