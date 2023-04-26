#include "scanTargetButton.h"
#include "playerInfo.h"
#include "targetsContainer.h"
#include "spaceObjects/playerSpaceship.h"
#include "gui/gui2_button.h"
#include "gui/gui2_progressbar.h"
#include "components/scanning.h"
#include "components/target.h"


GuiScanTargetButton::GuiScanTargetButton(GuiContainer* owner, string id, TargetsContainer* targets)
: GuiElement(owner, id), targets(targets)
{
    button = new GuiButton(this, id + "_BUTTON", "Scan", [this]() {
        if (my_spaceship && this->targets && this->targets->get())
            my_player_info->commandScan(this->targets->get());
    });
    button->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    progress = new GuiProgressbar(this, id + "_PROGRESS", 0, 6.0f, 0.0);
    progress->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiScanTargetButton::onUpdate()
{
    setVisible(my_spaceship.hasComponent<ScienceScanner>());
}

void GuiScanTargetButton::onDraw(sp::RenderTarget& target)
{
    auto ss = my_spaceship.getComponent<ScienceScanner>();
    if (!ss)
        return;

    if (ss->delay > 0.0f)
    {
        progress->show();
        progress->setRange(0, ss->max_scanning_delay);
        progress->setValue(ss->delay);
        button->hide();
    }
    else
    {
        sp::ecs::Entity obj;
        if (targets)
            obj = targets->get();

        button->show();
        auto scanstate = obj.getComponent<ScanState>();
        if (scanstate && scanstate->getStateFor(my_spaceship) != ScanState::State::FullScan)
            button->enable();
        else
            button->disable();
        progress->hide();
    }
}
