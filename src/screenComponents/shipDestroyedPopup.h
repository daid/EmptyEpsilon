#ifndef SHIP_DESTROYED_POPUP_H
#define SHIP_DESTROYED_POPUP_H

#include "gui/gui2_element.h"
#include "timer.h"
#include "spaceObjects/playerSpaceship.h"


class GuiPanel;
class GuiCanvas;
class GuiOverlay;

class GuiShipDestroyedPopup : public GuiElement
{
private:
    GuiOverlay* ship_destroyed_overlay;
    GuiOverlay* ship_docking_overlay;
    GuiOverlay* ship_docked_overlay;
    GuiCanvas* owner;
    sp::SystemTimer show_timeout;
    sp::SystemTimer docking_timeout;
    sp::SystemTimer docked_timeout;
    sp::SystemTimer return_timeout;
    bool retrievable;
public:
    GuiShipDestroyedPopup(GuiCanvas* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//SHIP_DESTROYED_POPUP_H