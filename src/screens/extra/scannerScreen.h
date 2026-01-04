#pragma once

#include "gui/gui2_overlay.h"

class GuiLabel;
class GuiProgressbar;
class GuiScanningDialog;

class ScannerScreen : public GuiOverlay
{
private:
    GuiLabel* label;
    GuiProgressbar* progress;
    GuiScanningDialog* dialog;
public:
    ScannerScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& renderer) override;
};
