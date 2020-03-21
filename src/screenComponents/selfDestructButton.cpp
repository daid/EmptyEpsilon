#include <i18n.h>
#include "selfDestructButton.h"
#include "gui/colorConfig.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_button.h"

GuiSelfDestructButton::GuiSelfDestructButton(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    activate_button = new GuiButton(this, id + "_ACTIVATE", tr("Self destruct"), [this](){
        activate_button->hide();
        confirm_button->show();
        cancel_button->show();
    });
    activate_button->setColors(colorConfig.button_red)->setIcon("gui/icons/self-destruct")->setSize(GuiElement::GuiSizeMax, 50);

    confirm_button = new GuiButton(this, id + "_CONFIRM", tr("selfdestruct", "Confirm!"), [this](){
        confirm_button->hide();
        if (my_spaceship)
            my_spaceship->commandActivateSelfDestruct();
    });
    confirm_button->setIcon("gui/icons/self-destruct")->hide()->setPosition(0, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    cancel_button = new GuiButton(this, id + "_CANCEL", tr("selfdestruct","Cancel"), [this](){
        activate_button->show();
        confirm_button->hide();
        cancel_button->hide();
        if (my_spaceship)
            my_spaceship->commandCancelSelfDestruct();
    });
    cancel_button->setIcon("gui/icons/self-destruct")->hide()->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiSelfDestructButton::onDraw(sf::RenderTarget& window)
{
}

void GuiSelfDestructButton::onHotkey(const HotkeyResult& key)
{
    if (key.category == "ENGINEERING" && my_spaceship)
    {
        if (key.hotkey == "SELF_DESTRUCT_START" && activate_button->isVisible())
        {
            activate_button->hide();
            confirm_button->show();
            cancel_button->show();
        }
        if (key.hotkey == "SELF_DESTRUCT_CONFIRM" && confirm_button->isVisible())
        {
            confirm_button->hide();
            my_spaceship->commandActivateSelfDestruct();
        }
        if (key.hotkey == "SELF_DESTRUCT_CANCEL" && cancel_button->isVisible())
        {
            activate_button->show();
            confirm_button->hide();
            cancel_button->hide();
            my_spaceship->commandCancelSelfDestruct();
        }
    }
}
