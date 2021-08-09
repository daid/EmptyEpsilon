#include "alertOverlay.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"


AlertLevelOverlay::AlertLevelOverlay(GuiContainer* owner)
: GuiElement(owner, "")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void AlertLevelOverlay::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship)
        return;

    sf::Color color;
    //string text;
    //float text_size;

    switch(my_spaceship->alert_level)
    {
    case AL_RedAlert:
        color = sf::Color(255, 0, 0);
        //text = "";
        //text_size = 70;
        break;
    case AL_YellowAlert:
        color = sf::Color(255, 255, 0);
        //text = "";
        //text_size = 60;
        break;
    case AL_Normal:
    default:
        return;
    }

    renderer.drawSprite("gui/alertOverlay.png", getCenterPoint(), 772, color);
    //renderer.drawText(sp::Rect(getCenterPoint() - glm::vec2(0, 300), glm::vec2(0, 0)), text, sp::Alignment::Center, text_size, main_font, color);
}
