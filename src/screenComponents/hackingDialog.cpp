#include "hackingDialog.h"
#include "playerInfo.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"

GuiHackingDialog::GuiHackingDialog(GuiContainer* owner, string id)
: GuiOverlay(owner, id, sf::Color(0,0,0,64))
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    hide();

    minigame_box = new GuiPanel(this, id + "_BOX");
    minigame_box->setSize(500, 545)->setPosition(0, 0, ACenter);

    status_label = new GuiLabel(minigame_box, "", "...", 25);
    status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 30);

    hacking_status_label = new GuiLabel(minigame_box, "", "", 25);
    hacking_status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 0);

    for(int x=0; x<hacking_field_size; x++)
    {
        for(int y=0; y<hacking_field_size; y++)
        {
            field_item[x][y].button = new GuiToggleButton(minigame_box, "", "", [this, x, y](bool value) { field_item[x][y].button->setValue(!value); onFieldClick(x, y); } );
            field_item[x][y].button->setSize(50, 50);
            field_item[x][y].button->setPosition(25 + x * 50, 75 + y * 50);
        }
    }
    reset_button = new GuiButton(minigame_box, "", "Reset", [this]()
    {
        resetMinigame();
    });
    reset_button->setSize(200, 50);
    reset_button->setPosition(25, 75 + hacking_field_size * 50, ATopLeft);

    GuiButton* close_button = new GuiButton(minigame_box, "", "Close", [this]()
    {
        hide();
    });
    close_button->setSize(200, 50);
    close_button->setPosition(-25, 75 + hacking_field_size * 50, ATopRight);
    
    progress_bar = new GuiProgressbar(minigame_box, "", 0, 1, 0.0);
    progress_bar->setPosition(-25, 75, ATopRight);
    progress_bar->setSize(50, hacking_field_size * 50);

    target_selection_box = new GuiPanel(this, id + "_BOX");
    target_selection_box->setSize(300, 545)->setPosition(400, 0, ACenter);

    GuiLabel* target_selection_label = new GuiLabel(target_selection_box, "", "Target system:", 25);
    target_selection_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 15);
    
    target_list = new GuiListbox(target_selection_box, "", [this](int index, string value)
    {
        target_system = value;
        resetMinigame();
    });
    target_list->setPosition(25, 75, ATopLeft);
    target_list->setSize(250, 445);
}

void GuiHackingDialog::open(P<SpaceObject> target)
{
    this->target = target;
    show();
    while(target_list->entryCount() > 0)
        target_list->removeEntry(0);
    std::vector<std::pair<string, float> > targets = target->getHackingTargets();
    for(std::pair<string, float>& target : targets)
    {
        target_list->addEntry(target.first, target.first);
    }
    if (targets.size() == 1)
    {
        target_selection_box->hide();
        target_system = targets[0].first;
        resetMinigame();
    }else{
        target_selection_box->show();
        disableMinigame();
    }
}

void GuiHackingDialog::onDraw(sf::RenderTarget& window)
{
    if (!target)
    {
        hide();
        return;
    }
    GuiOverlay::onDraw(window);
    if (correct_count == (hacking_field_size * hacking_field_size - bomb_count))
    {
        if (reset_time - engine->getElapsedTime() < 0.0)
        {
            if (my_spaceship)
            {
                my_spaceship->commandHackingFinished(target, target_system);
            }
            resetMinigame();
        }else{
            progress_bar->setValue((reset_time - engine->getElapsedTime()) / auto_reset_time);
        }
    }
    if (target_system != "")
    {
        std::vector<std::pair<string, float> > targets = target->getHackingTargets();
        for(std::pair<string, float>& target : targets)
        {
            if (target.first == target_system)
            {
                hacking_status_label->setText("Hacked " + target_system + ": " + string(int(target.second * 100.0f + 0.5f)) + "%");
                break;
            }
        }
    }
}

bool GuiHackingDialog::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiHackingDialog::resetMinigame()
{
    for(int x=0; x<hacking_field_size; x++)
    {
        for(int y=0; y<hacking_field_size; y++)
        {
            FieldItem& item = field_item[x][y];
            item.button->setText("");
            item.button->setValue(false);
            item.button->enable();
            item.bomb = false;
        }
    }
    for(int n=0; n<bomb_count; n++)
    {
        int x = irandom(0, hacking_field_size - 1);
        int y = irandom(0, hacking_field_size - 1);
        
        if (field_item[x][y].bomb)
        {
            n--;
            continue;
        }
        field_item[x][y].bomb = true;
    }
    error_count = 0;
    correct_count = 0;
    
    progress_bar->setValue(0.0f);
    status_label->setText("Hacking in progress: 0%");
    reset_button->enable();
}

void GuiHackingDialog::disableMinigame()
{
    status_label->setText("Select hacking target...");
    
    for(int x=0; x<hacking_field_size; x++)
    {
        for(int y=0; y<hacking_field_size; y++)
        {
            FieldItem& item = field_item[x][y];
            item.button->setText("");
            item.button->setValue(false);
            item.button->disable();
        }
    }
    reset_button->disable();
}

void GuiHackingDialog::onFieldClick(int x, int y)
{
    FieldItem& item = field_item[x][y];
    if (item.button->getValue() || item.button->getText() == "X" || error_count > 1 || correct_count == (hacking_field_size * hacking_field_size - bomb_count))
    {
        //Unpressing an already pressed button.
        return;
    }
    item.button->setValue(true);
    if (item.bomb)
    {
        item.button->setText("X");
        item.button->setValue(false);
        error_count++;
    }else{
        correct_count++;
        int bomb_count = 0;
        if (x > 0 && y > 0 && field_item[x-1][y-1].bomb) bomb_count++;
        if (x > 0 && field_item[x-1][y].bomb) bomb_count++;
        if (x > 0 && y < hacking_field_size - 1 && field_item[x-1][y+1].bomb) bomb_count++;

        if (y > 0 && field_item[x][y-1].bomb) bomb_count++;
        if (y < hacking_field_size - 1 && field_item[x][y+1].bomb) bomb_count++;

        if (x < hacking_field_size - 1 && y > 0 && field_item[x+1][y-1].bomb) bomb_count++;
        if (x < hacking_field_size - 1 && field_item[x+1][y].bomb) bomb_count++;
        if (x < hacking_field_size - 1 && y < hacking_field_size - 1 && field_item[x+1][y+1].bomb) bomb_count++;
        
        if (bomb_count < 1)
            item.button->setText("");
        else
            item.button->setText(string(bomb_count));
        
        if (bomb_count < 1)
        {
            if (x > 0 && y > 0) onFieldClick(x - 1, y - 1);
            if (x > 0)  onFieldClick(x - 1, y);
            if (x > 0 && y < hacking_field_size - 1) onFieldClick(x - 1, y + 1);

            if (y > 0)  onFieldClick(x, y - 1);
            if (y < hacking_field_size - 1)  onFieldClick(x, y + 1);

            if (x < hacking_field_size - 1 && y > 0)  onFieldClick(x + 1, y - 1);
            if (x < hacking_field_size - 1)  onFieldClick(x + 1, y);
            if (x < hacking_field_size - 1 && y < hacking_field_size - 1)  onFieldClick(x + 1, y + 1);
        }
    }
    
    if (error_count > 1)
    {
        status_label->setText("Hacking FAILED");
        progress_bar->setValue(0.0f);
    }else if (correct_count == (hacking_field_size * hacking_field_size - bomb_count))
    {
        status_label->setText("Hacking SUCCESS");
        reset_time = engine->getElapsedTime() + auto_reset_time;
        progress_bar->setValue(1.0f);
    }else{
        status_label->setText("Hacking in progress: " + string(correct_count * 100 / (hacking_field_size * hacking_field_size - bomb_count)) + "%");
        progress_bar->setValue(float(correct_count) / float(hacking_field_size * hacking_field_size - bomb_count));
    }
}
