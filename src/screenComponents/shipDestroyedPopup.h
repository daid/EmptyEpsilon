#ifndef GUI_SHIP_DESTROYED_RETURN_TIMEOUT_H
#define GUI_SHIP_DESTROYED_RETURN_TIMEOUT_H

#include "gui/gui2.h"

class GuiShipDestroyedPopup : public GuiElement
{
private:
    GuiBox* frame;
    GuiCanvas* owner;
    float show_timeout;
public:
    GuiShipDestroyedPopup(GuiCanvas* owner);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SHIP_DESTROYED_RETURN_TIMEOUT_H
