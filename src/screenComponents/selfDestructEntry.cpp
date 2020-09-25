#include <i18n.h>
#include "playerInfo.h"
#include "selfDestructEntry.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_autolayout.h"

GuiSelfDestructEntry::GuiSelfDestructEntry(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    for(int n=0; n<max_crew_positions; n++)
        has_position[n] = false;

    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(this, id + "_BOX");
    box->setPosition(0, 0, ACenter);
    GuiAutoLayout* layout = new GuiAutoLayout(box, id + "_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    layout->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    (new GuiLabel(layout, id + "_LABEL", tr("Self destruct activated!"), 50))->setSize(GuiElement::GuiSizeMax, 80);
    code_label = new GuiLabel(layout, id + "_CODE_LABEL", "", 30);
    code_label->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    code_entry = new GuiElement(layout, id + "_ENTRY_ELEMENT");
    code_entry->setSize(250, 320);

    code_entry_code_label = new GuiLabel(code_entry, id + "_ENTRY_LABEL", "Enter [A]", 30);
    code_entry_code_label->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    code_entry_label = new GuiLabel(code_entry, id + "_ENTRY_LABEL", "", 30);
    code_entry_label->addBackground()->setPosition(0, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiButton(code_entry, id + "_BUTTON_7", "7", [this]() {code_entry_label->setText(code_entry_label->getText() + "7");}))->setSize(50, 50)->setPosition(50, 100, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_8", "8", [this]() {code_entry_label->setText(code_entry_label->getText() + "8");}))->setSize(50, 50)->setPosition(100, 100, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_9", "9", [this]() {code_entry_label->setText(code_entry_label->getText() + "9");}))->setSize(50, 50)->setPosition(150, 100, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_4", "4", [this]() {code_entry_label->setText(code_entry_label->getText() + "4");}))->setSize(50, 50)->setPosition(50, 150, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_5", "5", [this]() {code_entry_label->setText(code_entry_label->getText() + "5");}))->setSize(50, 50)->setPosition(100, 150, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_6", "6", [this]() {code_entry_label->setText(code_entry_label->getText() + "6");}))->setSize(50, 50)->setPosition(150, 150, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_1", "1", [this]() {code_entry_label->setText(code_entry_label->getText() + "1");}))->setSize(50, 50)->setPosition(50, 200, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_2", "2", [this]() {code_entry_label->setText(code_entry_label->getText() + "2");}))->setSize(50, 50)->setPosition(100, 200, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_3", "3", [this]() {code_entry_label->setText(code_entry_label->getText() + "3");}))->setSize(50, 50)->setPosition(150, 200, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_Clr", "Clr", [this]() {code_entry_label->setText("");}))->setSize(50, 50)->setPosition(50, 250, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_0", "0", [this]() {code_entry_label->setText(code_entry_label->getText() + "0");}))->setSize(50, 50)->setPosition(100, 250, ATopLeft);
    (new GuiButton(code_entry, id + "_BUTTON_OK", "OK", [this]() {
        if (my_spaceship)
            my_spaceship->commandConfirmDestructCode(code_entry_position, code_entry_label->getText().toInt());
        code_entry_label->setText("");
    }))->setSize(50, 50)->setPosition(150, 250, ATopLeft);
}

void GuiSelfDestructEntry::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        if (my_spaceship->activate_self_destruct)
        {
            box->show();
            string codes = "";
            int lines = 0;
            code_entry_position = -1;
            for(int n=0; n<PlayerSpaceship::max_self_destruct_codes; n++)
            {
                if (has_position[my_spaceship->self_destruct_code_show_position[n]])
                {
                    if (lines > 0)
                        codes = codes + "\n";
                    codes = codes + tr("Code [{letter}]: {self_destruct_code}").format({{"letter", string(char('A' + n))}, {"self_destruct_code", string(my_spaceship->self_destruct_code[n])}});

                    lines++;
                }
                if (has_position[my_spaceship->self_destruct_code_entry_position[n]] && !my_spaceship->self_destruct_code_confirmed[n] && code_entry_position < 0)
                {
                    code_entry_position = n;
                }
            }
            code_label->setSize(GuiElement::GuiSizeMax, 30 + 30 * lines);
            code_label->setText(codes);
            code_label->setVisible(lines > 0);

            code_entry_code_label->setText(tr("selfdestruct", "Enter [{letter}]").format({{"letter", string(char('A' + code_entry_position))}}));

            code_entry->setVisible(code_entry_position > -1);

            if (code_entry->isVisible())
                box->setSize(600, code_entry->getPositionOffset().y + code_entry->getSize().y);
            else if (code_label->isVisible())
                box->setSize(600, code_label->getPositionOffset().y + code_label->getSize().y);
            else
                box->setSize(600, 80);
        }else{
            box->hide();
        }
    }else{
        box->hide();
    }
}
