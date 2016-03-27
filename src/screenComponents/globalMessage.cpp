#include "gameGlobalInfo.h"
#include "globalMessage.h"

GuiGlobalMessage::GuiGlobalMessage(GuiContainer* owner)
: GuiElement(owner, "GLOBAL_MESSAGE")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "GLOBAL_MESSAGE_BOX");
    box->setSize(800, 100)->setPosition(0, 250, ATopCenter);
    label = new GuiLabel(box, "GLOBAL_MESSAGE_LABEL", "...", 40);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ACenter);
}

void GuiGlobalMessage::onDraw(sf::RenderTarget& window)
{
    if (gameGlobalInfo->global_message_timeout > 0.0)
    {
        box->show();
        label->setText(gameGlobalInfo->global_message);
    }else{
        box->hide();
    }
}
