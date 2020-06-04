#include "tractorBeamScreen.h"

#include "screenComponents/tractorBeamControl.h"
#include "screenComponents/customShipFunctions.h"

TractorBeamScreen::TractorBeamScreen(GuiContainer* owner)
: GuiOverlay(owner, "TRACTOR_BEAM_SCREEN", colorConfig.background)
{
    (new GuiTractorBeamControl(this, "TRACTOR_VIEW"))->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiCustomShipFunctions(this, tractorView, "", my_spaceship))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}
