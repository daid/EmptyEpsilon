#include "factions.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_selector.h"
#include "factionInfo.h"
#include "GMActions.h"

#define MARGIN 10
#define CELL_SIZE 50
#define LABEL_SIZE 160

GuiFactions::GuiFactions(GuiContainer *owner)
    : GuiOverlay(owner, "FACTIONS_OVERLAY", sf::Color(0, 0, 0, 128)), faction_a(-1), faction_b(-1)
{
    this->setBlocking(true);
    GuiPanel *box = new GuiPanel(this, "PANEL");
    int cellsSize = factionInfo.size() * CELL_SIZE;
    box->setPosition(0, 0, ACenter)->setSize(2 * (MARGIN + LABEL_SIZE) + cellsSize, MARGIN + LABEL_SIZE + cellsSize);
    (new GuiButton(box, "", "X", [this]() { this->onClose(); }))->setPosition(-MARGIN, MARGIN, ATopRight)->setSize(30, 30);

    for (unsigned int i = 0; i < factionInfo.size(); i++)
    {
        GuiLabel *label = new GuiLabel(box, "", factionInfo[i]->getName(), 30);
        label->setAlignment(ACenterRight)->setPosition(MARGIN, MARGIN + LABEL_SIZE + i * CELL_SIZE, ATopLeft)->setSize(LABEL_SIZE - MARGIN, CELL_SIZE - MARGIN);
        h_labels.push_back(label);
        label = new GuiLabel(box, "", factionInfo[i]->getName(), 30);
        label->setAlignment(ACenterLeft)->setVertical()->setPosition(MARGIN + LABEL_SIZE + i * CELL_SIZE, MARGIN, ATopLeft)->setSize(CELL_SIZE - MARGIN, LABEL_SIZE - MARGIN);
        v_labels.push_back(label);
        for (unsigned int j = 0; j < factionInfo.size(); j++)
        {
            if (i == j)
            {
                buttons.push_back(nullptr);
            }
            else
            {
                GuiButton *button = new GuiButton(box, "", "", [this, i, j]() { this->onSelectFactions(i, j); });
                button->setPosition(MARGIN + LABEL_SIZE + j * CELL_SIZE, MARGIN + LABEL_SIZE + i * CELL_SIZE, ATopLeft)->setSize(CELL_SIZE - MARGIN, CELL_SIZE - MARGIN);
                buttons.push_back(button);
            }
        }
    }
    editPanel = new GuiElement(box, "EDIT_PANEL");
    editPanel->hide();
    editPanel->setPosition(0, MARGIN + LABEL_SIZE, ATopRight)->setSize(2 * MARGIN + LABEL_SIZE, cellsSize);

    faction_a_edit_label = new GuiLabel(editPanel, "", "", 30);
    faction_a_edit_label->setAlignment(ACenter)->setPosition(0, MARGIN, ATopCenter)->setSize(LABEL_SIZE - MARGIN, CELL_SIZE - MARGIN);

    (new GuiLabel(editPanel, "", "consider", 15))->setAlignment(ACenter)->setPosition(0, MARGIN * 2 + CELL_SIZE, ATopCenter)->setSize(LABEL_SIZE - MARGIN, CELL_SIZE - MARGIN);

    faction_b_edit_label = new GuiLabel(editPanel, "", "", 30);
    faction_b_edit_label->setAlignment(ACenter)->setPosition(0, MARGIN * 3 + CELL_SIZE * 2, ATopCenter)->setSize(LABEL_SIZE - MARGIN, CELL_SIZE - MARGIN);

    (new GuiLabel(editPanel, "", "to be", 15))->setAlignment(ACenter)->setPosition(0, MARGIN * 4 + CELL_SIZE * 3, ATopCenter)->setSize(LABEL_SIZE - MARGIN, CELL_SIZE - MARGIN);

    edit_selector = new GuiSelector(editPanel, "", [this](int selection_index, string value) {
        if (faction_a != -1 && faction_b != -1) {
            gameMasterActions->commandSetFactionsState(faction_a, faction_b, selection_index);
        }
    });
    edit_selector->setPosition(0, MARGIN * 5 + CELL_SIZE * 4, ATopCenter)->setSize(LABEL_SIZE - MARGIN, CELL_SIZE - MARGIN);
    edit_selector->setOptions({getFactionVsFactionStateName(FVF_Friendly), getFactionVsFactionStateName(FVF_Neutral), getFactionVsFactionStateName(FVF_Enemy)});
}

void GuiFactions::onSelectFactions(unsigned int i, unsigned int j)
{
    this->deSelectFactions();
    faction_a = i;
    faction_b = j;

    this->buttons[faction_a * factionInfo.size() + faction_b]->setActive(true);
    h_labels[faction_a]->addBackground();
    v_labels[faction_b]->addBackground();
    editPanel->show();
    faction_a_edit_label->setText(factionInfo[faction_a]->getName());
    faction_b_edit_label->setText(factionInfo[faction_b]->getName());
    edit_selector->setSelectionIndex(factionInfo[i]->states[j]);
}

void GuiFactions::deSelectFactions()
{
    if (faction_a != -1 && faction_b != -1)
    {
        this->buttons[faction_a * factionInfo.size() + faction_b]->setActive(false);
        h_labels[faction_a]->removeBackground();
        v_labels[faction_b]->removeBackground();
    }
    faction_a = -1;
    faction_b = -1;
    editPanel->hide();
}

void GuiFactions::onClose()
{
    this->deSelectFactions();
    this->hide();
}
void GuiFactions::onDraw(sf::RenderTarget &window)
{
    GuiOverlay::onDraw(window);
    for (unsigned int i = 0; i < factionInfo.size(); i++)
    {
        for (unsigned int j = 0; j < factionInfo.size(); j++)
        {
            if (i != j)
            {
                this->buttons[i * factionInfo.size() + j]->setText(getFactionVsFactionStateName(factionInfo[i]->states[j])[0]);
            }
        }
    }
}