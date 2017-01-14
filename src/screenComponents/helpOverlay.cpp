#include "helpOverlay.h"

#include "gui/gui2_button.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"

GuiHelpOverlay::GuiHelpOverlay(GuiCanvas* owner, string title, string contents)
: GuiElement(owner, "HELP_OVERLAY"), owner(owner)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    frame = new GuiPanel(this, "HELP_FRAME");
    frame->setPosition(0, 0, ACenter)->setSize(500, 700)->hide();
    
    (new GuiLabel(frame, "HELP_LABEL", title, 50))->setPosition(0, 25, ATopCenter)->setSize(GuiElement::GuiSizeMax, 60);

    text = new GuiScrollText(frame, "HELP_TEXT", contents);
    text->setTextSize(30)->setPosition(0, 110, ATopCenter)->setSize(450, 520);

    (new GuiButton(frame, "HELP_BUTTON", "Close", [this]() {
        frame->hide();
    }))->setPosition(0, -25, ABottomCenter)->setSize(300, 50);
}

void GuiHelpOverlay::setText(string new_text)
{
    help_text = new_text;
}

void GuiHelpOverlay::onDraw(sf::RenderTarget& window)
{
    if (frame->isVisible())
        text->setText(help_text);
}
