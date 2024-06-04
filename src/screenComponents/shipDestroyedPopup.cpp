#include "shipDestroyedPopup.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "soundManager.h"
#include "main.h"
#include "gameGlobalInfo.h"

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
    (new GuiPanel(ship_destroyed_overlay, "SHIP_DESTROYED_FRAME"))->setPosition(0, 0, sp::Alignment::Center)->setSize(800, 100);
    (new GuiLabel(ship_destroyed_overlay, "SHIP_DESTROYED_TEXT", "RETURNING TO ESS ODYSSEUS", 70))->setPosition(0, 0, sp::Alignment::Center)->setSize(800, 100);

    ship_docking_overlay = new GuiOverlay(this, "SHIP_DOCKING", glm::u8vec4(0, 0, 0, 128));
    (new GuiPanel(ship_docking_overlay, "SHIP_DOCKING_FRAME"))->setPosition(0, 0, sp::Alignment::Center)->setSize(800, 100);
    (new GuiLabel(ship_docking_overlay, "SHIP_DOCKING_TEXT", "AUTOMATED DOCKING IN PROGRESS", 70))->setPosition(0, 0, sp::Alignment::Center)->setSize(800, 100);

    ship_docked_overlay = new GuiOverlay(this, "SHIP_DOCKED", glm::u8vec4(0, 0, 0, 128));
    (new GuiPanel(ship_docked_overlay, "SHIP_DOCKED_FRAME"))->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);
    (new GuiLabel(ship_docked_overlay, "SHIP_DOCKED_TEXT", "DOCKING COMPLETE", 70))->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);

    retrievable = my_spaceship->getCanBeDestroyed();

    show_timeout.start(5.0);
}

void GuiShipDestroyedPopup::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        ship_destroyed_overlay->hide();
        ship_docking_overlay->hide();        
        ship_docked_overlay->hide();
        
        show_timeout.start(0.5);
        
    } else {
        if (!retrievable) {
            returnToShipSelection(this->owner->getRenderLayer());
            this->owner->destroy();    
        }
        else 
        {
            if (show_timeout.isExpired()) {
                soundManager->stopMusic();
                ship_destroyed_overlay->show();
                docking_timeout.start(4.5);
            }
            if (docking_timeout.isExpired()) {
                ship_destroyed_overlay->hide();
                ship_docking_overlay->show();
                docked_timeout.start(10.0);
            }
            if (docked_timeout.isExpired()) {
                ship_docking_overlay->hide();
                ship_docked_overlay->show();
                return_timeout.start(5.0);
            }
            if (return_timeout.isExpired()) {
                returnToShipSelection(this->owner->getRenderLayer());
                this->owner->destroy();
            }
        }
    }
}
