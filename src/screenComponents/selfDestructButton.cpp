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
    activate_button->setStyle("button.selfdestruct")->setIcon("gui/icons/self-destruct")->setSize(GuiElement::GuiSizeMax, 50);

    confirm_button = new GuiButton(this, id + "_CONFIRM", tr("selfdestruct", "Confirm!"), [this](){
        confirm_button->hide();
        if (my_spaceship)
            my_spaceship->commandActivateSelfDestruct();
    });
    confirm_button->setIcon("gui/icons/self-destruct")->hide()->setPosition(0, 50, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    cancel_button = new GuiButton(this, id + "_CANCEL", tr("button", "Cancel"), [this](){
        activate_button->show();
        confirm_button->hide();
        cancel_button->hide();
        if (my_spaceship)
            my_spaceship->commandCancelSelfDestruct();
    });
    cancel_button->setIcon("gui/icons/self-destruct")->hide()->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiSelfDestructButton::onUpdate()
{
    activate_button->setVisible(my_spaceship && my_spaceship->getCanSelfDestruct());

    if (my_spaceship && isVisible())
    {
        if (keys.engineering_self_destruct_start.getDown() && activate_button->isVisible())
        {
            activate_button->hide();
            confirm_button->show();
            cancel_button->show();
        }
        if (keys.engineering_self_destruct_confirm.getDown() && confirm_button->isVisible())
        {
            confirm_button->hide();
            my_spaceship->commandActivateSelfDestruct();
        }
        if (keys.engineering_self_destruct_cancel.getDown() && cancel_button->isVisible())
        {
            activate_button->show();
            confirm_button->hide();
            cancel_button->hide();
            my_spaceship->commandCancelSelfDestruct();
        }
    }
}

void GuiSelfDestructButton::onDraw(sp::RenderTarget& target)
{
}
