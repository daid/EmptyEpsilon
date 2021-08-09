#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "noiseOverlay.h"

GuiNoiseOverlay::GuiNoiseOverlay(GuiContainer* owner)
: GuiElement(owner, "NOISE_OVERLAY")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiNoiseOverlay::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
        return;

    //TODO_GFX: randomization
    renderer.drawTiled(rect, "noise.png");
}
