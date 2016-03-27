#include "playerInfo.h"
#include "selfDestructIndicator.h"

GuiSelfDestructIndicator::GuiSelfDestructIndicator(GuiContainer* owner)
: GuiElement(owner, "SELF_DESTRUCT_INDICATOR")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "SELF_DESTRUCT_INDICATOR_BOX");
    box->setSize(800, 150)->setPosition(0, 150, ATopCenter);
    (new GuiLabel(box, "SELF_DESTRUCT_INDICATOR_LABEL", "SELF DESTRUCT ACTIVATED", 50))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, -25, ACenter);
    label = new GuiLabel(box, "SELF_DESTRUCT_INDICATOR_LABEL2", "", 30);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 30, ACenter);
}

void GuiSelfDestructIndicator::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship && my_spaceship->activate_self_destruct)
    {
        box->show();

        if (my_spaceship->self_destruct_countdown <= 0.0f)
        {
            int todo = 0;
            for(int n=0; n<PlayerSpaceship::max_self_destruct_codes; n++)
                if (!my_spaceship->self_destruct_code_confirmed[n])
                    todo++;
            label->setText("Waiting for autorization input: " + string(todo) + " left");
        }else{
            if (my_spaceship->self_destruct_countdown <= 3.0f)
                label->setText("Have a nice day.");
            else
                label->setText("This ship will self-destruct in exactly 10 seconds.");
        }
    }else{
        box->hide();
    }
}
