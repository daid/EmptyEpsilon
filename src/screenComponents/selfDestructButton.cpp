#include "selfDestructButton.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_button.h"

GuiSelfDestructButton::GuiSelfDestructButton(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    activate_button = new GuiButton(this, id + "_ACTIVATE", "Self destruct", [this](){
        activate_button->hide();
        confirm_button->show();
        cancel_button->show();
    });
    activate_button->setIcon("gui/icons/self-destruct")->setSize(GuiElement::GuiSizeMax, 50);

    confirm_button = new GuiButton(this, id + "_CONFIRM", "Confirm!", [this](){
        confirm_button->hide();
        if (my_spaceship)
            my_spaceship->commandActivateSelfDestruct();
    });
    confirm_button->setIcon("gui/icons/self-destruct")->hide()->setPosition(0, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    cancel_button = new GuiButton(this, id + "_CANCEL", "Cancel", [this](){
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
