#include "gameGlobalInfo.h"
#include "globalMessage.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"

GuiGlobalMessage::GuiGlobalMessage(GuiContainer* owner)
: GuiElement(owner, "GLOBAL_MESSAGE")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(owner, "GLOBAL_MESSAGE_BOX");
    box->setPosition(0, 250, sp::Alignment::TopCenter);
    label = new GuiAutoSizeLabel(box, "GLOBAL_MESSAGE_LABEL", "...", {760, 60}, {760, 400}, 20, 40);
    label->setMargins(20)->setPosition(0, 0, sp::Alignment::Center);
}

void GuiGlobalMessage::onDraw(sp::RenderTarget& target)
{
    if (gameGlobalInfo->global_message_timeout > 0.0f)
    {
        box->show();
        label->setText(gameGlobalInfo->global_message);
    }else{
        box->hide();
    }
}
