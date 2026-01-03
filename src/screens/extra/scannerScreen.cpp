#include "scannerScreen.h"
#include "screenComponents/scanningDialog.h"

ScannerScreen::ScannerScreen(GuiContainer* owner)
: GuiOverlay(owner, "SCANNER_SCREEN", colorConfig.background)
{
    new GuiScanningDialog(this, "");
}
