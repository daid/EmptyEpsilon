#include "helpOverlay.h"

#include "gui/gui2_button.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"

#include <i18n.h>

GuiHelpOverlay::GuiHelpOverlay(GuiContainer* owner, string title, string contents)
: GuiElement(owner, "HELP_OVERLAY")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    frame = new GuiPanel(this, "HELP_FRAME");
    frame->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 700)->hide();

    (new GuiLabel(frame, "HELP_LABEL", title, 50))->setPosition(0, 25, sp::Alignment::TopCenter)->setSize(GuiElement::GuiSizeMax, 60);

    text = new GuiScrollText(frame, "HELP_TEXT", contents);
    text->setTextSize(30)->setPosition(0, 110, sp::Alignment::TopCenter)->setSize(450, 520);

    (new GuiButton(frame, "HELP_BUTTON", tr("hotkey_F1", "Close"), [this]() {
        frame->hide();
    }))->setPosition(0, -25, sp::Alignment::BottomCenter)->setSize(300, 50);
}

void GuiHelpOverlay::setText(string new_text)
{
    help_text = new_text;
}

void GuiHelpOverlay::onDraw(sp::RenderTarget& target)
{
    if (frame->isVisible())
        text->setText(help_text);
}
