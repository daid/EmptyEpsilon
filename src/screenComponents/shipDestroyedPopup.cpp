#include "shipDestroyedPopup.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_panel.h"

GuiShipDestroyedPopup::GuiShipDestroyedPopup(GuiCanvas* owner)
: GuiElement(owner, "SHIP_DESTROYED_POPUP"), owner(owner)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    ship_destroyed_overlay = new GuiOverlay(this, "SHIP_DESTROYED", sf::Color(0, 0, 0, 128));
    (new GuiPanel(ship_destroyed_overlay, "SHIP_DESTROYED_FRAME"))->setPosition(0, 0, ACenter)->setSize(500, 100);
    (new GuiLabel(ship_destroyed_overlay, "SHIP_DESTROYED_TEXT", tr("SHIP DESTROYED!"), 70))->setPosition(0, 0, ACenter)->setSize(500, 100);
    (new GuiButton(ship_destroyed_overlay, "SHIP_DESTROYED_BUTTON", tr("shipdestroyed", "Return"), [this]() {
        this->owner->destroy();
        soundManager->stopMusic();
        returnToShipSelection();
    }))->setPosition(0, 75, ACenter)->setSize(500, 50);

    show_timeout.restart();
}

void GuiShipDestroyedPopup::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        ship_destroyed_overlay->hide();
        show_timeout.restart();
    }else{
        if (show_timeout.getElapsedTime().asSeconds() > 5.0)
            ship_destroyed_overlay->show();
    }
}
