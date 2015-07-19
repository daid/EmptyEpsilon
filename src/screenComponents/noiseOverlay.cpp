#include "playerInfo.h"
#include "noiseOverlay.h"

GuiNoiseOverlay::GuiNoiseOverlay(GuiContainer* owner)
: GuiElement(owner, "NOISE_OVERLAY")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiNoiseOverlay::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
        return;
    
    sf::Sprite staticDisplay;
    textureManager.getTexture("noise.png")->setRepeated(true);
    textureManager.setTexture(staticDisplay, "noise.png");
    staticDisplay.setTextureRect(sf::IntRect(0, 0, 2048, 2048));
    staticDisplay.setOrigin(sf::Vector2f(1024, 1024));
    staticDisplay.setScale(3.0, 3.0);
    staticDisplay.setPosition(sf::Vector2f(random(-512, 512), random(-512, 512)));
    window.draw(staticDisplay);
}
