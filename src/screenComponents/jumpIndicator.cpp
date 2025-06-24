#include "playerInfo.h"
#include "jumpIndicator.h"
#include "components/jumpdrive.h"
#include "i18n.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

GuiJumpIndicator::GuiJumpIndicator(GuiContainer* owner)
: GuiElement(owner, "JUMP_INDICATOR")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "JUMP_BOX");
    box->setSize(800, 100)->setPosition(0, 200, sp::Alignment::TopCenter);
    label = new GuiLabel(box, "JUMP_LABEL", "Jump in: ", 50);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::Center);
}

void GuiJumpIndicator::onDraw(sp::RenderTarget& target)
{
    if (my_spaceship)
    {
        auto jump = my_spaceship.getComponent<JumpDrive>();
        if (jump && jump->delay > 0.0f) {
            box->show();
            if (jump->get_seconds_to_jump() == std::numeric_limits<int>::max())
                label->setText(tr("jumpcontrol", "Jump delayed"));
            else
                label->setText(tr("Jump in: {delay}").format({{"delay", string(jump->get_seconds_to_jump()) + tr("jumpcontrol", " sec.")}}));
        } else {
            box->hide();
        }
    }else{
        box->hide();
    }
}
