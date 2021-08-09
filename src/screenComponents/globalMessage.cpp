#include "gameGlobalInfo.h"
#include "globalMessage.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

GuiGlobalMessage::GuiGlobalMessage(GuiContainer* owner)
: GuiElement(owner, "GLOBAL_MESSAGE")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "GLOBAL_MESSAGE_BOX");
    box->setSize(800, 100)->setPosition(0, 250, sp::Alignment::TopCenter);
    label = new GuiLabel(box, "GLOBAL_MESSAGE_LABEL", "...", 40);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, sp::Alignment::Center);
}

void GuiGlobalMessage::onDraw(sp::RenderTarget& target)
{
    if (gameGlobalInfo->global_message_timeout > 0.0)
    {
        box->show();
        label->setText(gameGlobalInfo->global_message);
    }else{
        box->hide();
    }
}
