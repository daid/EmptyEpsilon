#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "jumpIndicator.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

GuiJumpIndicator::GuiJumpIndicator(GuiContainer* owner)
: GuiElement(owner, "JUMP_INDICATOR")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "JUMP_BOX");
    box->setSize(800, 100)->setPosition(0, 200, ATopCenter);
    label = new GuiLabel(box, "JUMP_LABEL", "Jump in: ", 50);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenter);
}

void GuiJumpIndicator::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship && my_spaceship->jump_delay > 0.0)
    {
        box->show();
        label->setText("Jump in: " + string(int(ceilf(my_spaceship->jump_delay))));
    }else{
        box->hide();
    }
}
