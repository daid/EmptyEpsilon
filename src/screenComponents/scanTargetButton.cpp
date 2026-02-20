#include "scanTargetButton.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"
#include "targetsContainer.h"
#include "gui/gui2_button.h"
#include "gui/gui2_progressbar.h"
#include "components/scanning.h"
#include "components/target.h"
#include "i18n.h"


GuiScanTargetButton::GuiScanTargetButton(GuiContainer* owner, string id, TargetsContainer* targets, bool allow_scanning)
: GuiElement(owner, id), targets(targets), allow_scanning(allow_scanning)
{
    button = new GuiButton(this, id + "_BUTTON", tr("scienceButton", "Scan"), [this]() {
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
    if (!ss) return;

    if (ss->delay > 0.0f)
    {
        if (allow_scanning && gameGlobalInfo->scanning_complexity == EScanningComplexity::SC_None)
        {
            progress
                ->setText(tr("scienceButton", "Scanning..."))
                ->setRange(0.0f, ss->max_scanning_delay)
                ->setValue(ss->delay)
                ->show();
            button->hide();
        }
        else
        {
            progress->hide();
            button
                ->setText(tr("scienceButton", "Scan initiated..."))
                ->disable();
        }
    }
    else
    {
        button->show();
        progress->hide();

        sp::ecs::Entity obj;
        if (targets) obj = targets->get();

        auto scanstate = obj.getComponent<ScanState>();
        if (scanstate && scanstate->getStateFor(my_spaceship) != ScanState::State::FullScan)
        {
            button
                ->setText(allow_scanning ? tr("sciencebutton", "Scan"): tr("sciencebutton", "Link to scanner"))
                ->enable();
        }
        else
        {
            button
                ->setText(tr("sciencebutton", "No scanner target"))
                ->disable();
        }
    }
}
