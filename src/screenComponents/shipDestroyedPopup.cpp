#include "shipDestroyedPopup.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_panel.h"

GuiShipDestroyedPopup::GuiShipDestroyedPopup(GuiCanvas* owner)
: GuiElement(owner, "SHIP_DESTROYED_POPUP"), owner(owner)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    frame = new GuiPanel(this, "SHIP_DESTROYED_FRAME");
    frame->setPosition(0, 0, ACenter)->setSize(700, 200);
    
    (new GuiLabel(frame, "SHIP_DESTROYED_TEXT", "SHIP DESTROYED!", 70))->setPosition(0, -25, ACenter)->setSize(0, 0);
    (new GuiButton(frame, "SHIP_DESTROYED_BUTTON", "Return", [this]() {
        this->owner->onKey(sf::Keyboard::Home, -1);
    }))->setPosition(0, 50, ACenter)->setSize(300, 50);
    
    show_timeout.restart();
}

void GuiShipDestroyedPopup::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        frame->hide();
        show_timeout.restart();
    }else{
        if (show_timeout.getElapsedTime().asSeconds() > 5.0)
            frame->show();
    }
}
