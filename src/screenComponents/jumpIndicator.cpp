#include "playerInfo.h"
#include "jumpIndicator.h"

GuiJumpIndicator::GuiJumpIndicator(GuiContainer* owner)
: GuiElement(owner, "JUMP_INDICATOR")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiBox(owner, "JUMP_BOX");
    box->setSize(800, 100)->setPosition(0, 200, ATopCenter);
    (new GuiLabel(box, "JUMP_LABEL", "Jump in: ", 50))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenter);
}

void GuiJumpIndicator::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship->jump_delay > 0.0)
    {
        box->show();
        label->setText("Jump in: " + string(int(ceilf(my_spaceship->jump_delay))));
    }else{
        box->hide();
    }
}
