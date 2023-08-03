#include "alertOverlay.h"
#include "playerInfo.h"


AlertLevelOverlay::AlertLevelOverlay(GuiContainer* owner)
: GuiElement(owner, "")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void AlertLevelOverlay::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship)
        return;
    auto pc = my_spaceship.getComponent<PlayerControl>();
    if (!pc)
        return;

    glm::u8vec4 color;
    //string text;
    //float text_size;

    switch(pc->alert_level)
    {
    case AlertLevel::RedAlert:
        color = glm::u8vec4(255, 0, 0, 255);
        //text = "";
        //text_size = 70;
        break;
    case AlertLevel::YellowAlert:
        color = glm::u8vec4(255, 255, 0, 255);
        //text = "";
        //text_size = 60;
        break;
    case AlertLevel::Normal:
    default:
        return;
    }

    renderer.drawSprite("gui/alertOverlay.png", getCenterPoint(), 772, color);
    //renderer.drawText(sp::Rect(getCenterPoint() - glm::vec2(0, 300), glm::vec2(0, 0)), text, sp::Alignment::Center, text_size, main_font, color);
}
