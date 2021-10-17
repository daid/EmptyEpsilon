#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
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

    renderer.drawTiled(sp::Rect{rect.position - glm::vec2{random(rect.size.x, 0), random(rect.size.y, 0)}, rect.size*2.0f}, "noise.png");
}
