#include "playerInfo.h"
#include "noiseOverlay.h"
#include "random.h"


GuiNoiseOverlay::GuiNoiseOverlay(GuiContainer* owner)
: GuiElement(owner, "NOISE_OVERLAY")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiNoiseOverlay::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
        return;

    renderer.drawTiled(rect, "noise.png", {random(0, 1), random(0, 1)});
}
