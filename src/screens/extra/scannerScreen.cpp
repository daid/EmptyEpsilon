#include "scannerScreen.h"
#include <i18n.h>
#include "playerInfo.h"
#include "gameGlobalInfo.h"

#include "components/scanning.h"
#include "screenComponents/scanningDialog.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"

ScannerScreen::ScannerScreen(GuiContainer* owner)
: GuiOverlay(owner, "SCANNER_SCREEN", colorConfig.background)
{
    (new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255}))
        ->setTextureTiled("gui/background/crosses.png");

    label = new GuiLabel(this, "SCANNER_LABEL", tr("scienceButton", "Scanner inactive"), 40.0f);
    label
        ->setSize(GuiElement::GuiSizeMax, 40.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::Center);
    dialog = new GuiScanningDialog(this, "SCANNER");
    progress = new GuiProgressbar(this, "SCANNER_PROGRESS", 0.0f, 6.0f, 0.0f);
    progress
        ->setPosition(0.0f, 0.0f, sp::Alignment::Center)
        ->setSize(500.0f, 50.0f)
        ->hide();
}

void ScannerScreen::onDraw(sp::RenderTarget& target)
{
    auto ss = my_spaceship.getComponent<ScienceScanner>();
    if (!ss) return;

    if (ss->delay > 0.0f)
    {
        if (gameGlobalInfo->scanning_complexity == EScanningComplexity::SC_None)
        {
            progress
                ->setText(tr("scienceButton", "Scanning..."))
                ->setRange(0.0f, ss->max_scanning_delay)
                ->setValue(ss->delay)
                ->show();
            label->hide();
            dialog->hide();
        }
        else
        {
            progress->hide();
            label
                ->setText(tr("scienceButton", "Scanning..."))
                ->show();
            dialog->show();
        }
    }
    else
    {
        progress->hide();
        label
            ->setText(tr("scienceButton", "Scanner inactive"))
            ->show();
        dialog->show();
    }

    GuiOverlay::onDraw(target);
}
