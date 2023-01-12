#include "selfDestructIndicator.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/selfdestruct.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

GuiSelfDestructIndicator::GuiSelfDestructIndicator(GuiContainer* owner)
: GuiElement(owner, "SELF_DESTRUCT_INDICATOR")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "SELF_DESTRUCT_INDICATOR_BOX");
    box->setSize(800, 150)->setPosition(0, 150, sp::Alignment::TopCenter);
    (new GuiLabel(box, "SELF_DESTRUCT_INDICATOR_LABEL", tr("SELF DESTRUCT ACTIVATED"), 50))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, -25, sp::Alignment::Center);
    label = new GuiLabel(box, "SELF_DESTRUCT_INDICATOR_LABEL2", "", 30);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 30, sp::Alignment::Center);
}

void GuiSelfDestructIndicator::onDraw(sp::RenderTarget& target)
{
    box->hide();
    if (!my_spaceship)
        return;
    auto self_destruct = my_spaceship->entity.getComponent<SelfDestruct>();
    if (!self_destruct || !self_destruct->active)
        return;

    box->show();

    if (self_destruct->countdown <= 0.0f)
    {
        int todo = 0;
        for(int n=0; n<SelfDestruct::max_codes; n++)
            if (!self_destruct->confirmed[n])
                todo++;
        label->setText(tr("Waiting for autorization input: {codes} left").format({{"codes", string(todo)}}));
    }else{
        if (self_destruct->countdown <= 3.0f)
        {
            label->setText(tr("Have a nice day."));
        }
        else
        {
            label->setText(tr("This ship will self-destruct in {seconds} seconds.").format({{"seconds", string(int(std::nearbyint(self_destruct->countdown)))}}));
        }
    }
}
