#include <i18n.h>
#include "globalMessageEntryView.h"
#include "GMActions.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_button.h"


GuiGlobalMessageEntryView::GuiGlobalMessageEntryView(GuiContainer* owner)
: GuiOverlay(owner, "GLOBAL_MESSAGE_ENTRY", glm::u8vec4(0, 0, 0, 128))
{
    GuiPanel* box = new GuiPanel(this, "FRAME");
    box->setPosition(0, 0, sp::Alignment::Center)->setSize(800, 150);

    message_entry = new GuiTextEntry(box, "MESSAGE_ENTRY", "");
    message_entry->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(700, 50);

    (new GuiButton(box, "CLOSE_BUTTON", tr("button", "Cancel"), [this]() {
        this->hide();
    }))->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(300, 50);

    (new GuiButton(box, "SEND_BUTTON", tr("button", "Send"), [this]() {
        string message = message_entry->getText();
        gameMasterActions->commandSendGlobalMessage(message);
        this->hide();
    }))->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(300, 50);
}

bool GuiGlobalMessageEntryView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{   //Catch clicks.
    return true;
}
