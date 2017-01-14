#ifndef SHIP_DESTROYED_POPUP_H
#define SHIP_DESTROYED_POPUP_H

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

#endif//SHIP_DESTROYED_POPUP_H
