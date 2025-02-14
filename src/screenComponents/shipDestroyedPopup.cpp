#include "shipDestroyedPopup.h"
#include "i18n.h"
#include "playerInfo.h"
#include "soundManager.h"
#include "main.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_panel.h"

GuiShipDestroyedPopup::GuiShipDestroyedPopup(GuiCanvas* owner)
: GuiElement(owner, "SHIP_DESTROYED_POPUP"), owner(owner)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    ship_destroyed_overlay = new GuiOverlay(this, "SHIP_DESTROYED", glm::u8vec4(0, 0, 0, 128));
    (new GuiPanel(ship_destroyed_overlay, "SHIP_DESTROYED_FRAME"))->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);
    (new GuiLabel(ship_destroyed_overlay, "SHIP_DESTROYED_TEXT", tr("SHIP DESTROYED!"), 70))->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);
    (new GuiButton(ship_destroyed_overlay, "SHIP_DESTROYED_BUTTON", tr("shipdestroyed", "Return"), [this]() {
        soundManager->stopMusic();
        returnToShipSelection(this->owner->getRenderLayer());
        this->owner->destroy();
    }))->setPosition(0, 75, sp::Alignment::Center)->setSize(500, 50);

    show_timeout.start(5.0);
}

void GuiShipDestroyedPopup::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        ship_destroyed_overlay->hide();
        show_timeout.start(5.0);
    }else{
        if (show_timeout.isExpired())
            ship_destroyed_overlay->show();
    }
}
