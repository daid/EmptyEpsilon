#include "onScreenKeyboard.h"

#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_autolayout.h"

OnScreenKeyboardControl::OnScreenKeyboardControl(GuiContainer* owner, GuiTextEntry* _target)
: GuiElement(owner, "")
{
    this->target = _target;
    auto rows = new GuiElement(this, "");
    rows->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    auto row = new GuiElement(rows, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    addButtonsToRow(row, "qwertyuiop[]");
    addButtonsToRow(row, "789");

    row = new GuiElement(rows, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiElement(row, ""))->setSize(25, 50);
    addButtonsToRow(row, "asdfghjkl;'");
    (new GuiElement(row, ""))->setSize(25, 50);
    addButtonsToRow(row, "456");

    row = new GuiElement(rows, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiElement(row, ""))->setSize(50, 50);
    addButtonsToRow(row, "zxcvbnm,./");
    (new GuiElement(row, ""))->setSize(50, 50);
    addButtonsToRow(row, "123");

    row = new GuiElement(rows, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiElement(row, ""))->setSize(25, 50);
    (new GuiButton(row, "", "", [this](){
        target->setText(target->getText() + " ");
    }))->setSize(400, 50);
    (new GuiButton(row, "", "<--", [this](){
        target->setText(target->getText().substr(0, -1));
    }))->setSize(150, 50);
    (new GuiElement(row, ""))->setSize(25, 50);
    addButtonsToRow(row, "0-=");
}

void OnScreenKeyboardControl::addButtonsToRow(GuiContainer* row, const char* button_keys)
{
    for(const char* c=button_keys; *c; c++)
    {
        char chr = *c;
        (new GuiButton(row, "", string(chr), [this, chr](){
            target->setText(target->getText() + string(chr));
        }))->setSize(50, 50);
    }
}
