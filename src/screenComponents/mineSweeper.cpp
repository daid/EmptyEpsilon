#include "mineSweeper.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"

MineSweeper::MineSweeper(GuiHackingDialog* owner, string id, int difficulty)
: MiniGame(owner, id, difficulty) {
    field_item = new FieldItem*[difficulty];
    for(int x=0; x<difficulty; x++)
    {
        field_item[x] = new FieldItem[difficulty];
        for(int y=0; y<difficulty; y++)
        {
            field_item[x][y].button = new GuiToggleButton(this, "", "", [this, x, y](bool value) { field_item[x][y].button->setValue(!value); onFieldClick(x, y); } );
            field_item[x][y].button->setSize(50, 50);
            field_item[x][y].button->setPosition(25 + x * 50, 75 + y * 50);
        }
    }
}

void MineSweeper::disable()
{
    MiniGame::disable();
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem& item = field_item[x][y];
            item.button->setText("");
            item.button->setValue(false);
            item.button->disable();
        }
    }
}

void MineSweeper::reset()
{
    game_complete = false;
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem& item = field_item[x][y];
            item.button->setText("");
            item.button->setValue(false);
            item.button->enable();
            item.bomb = false;
        }
    }
    for(int n=0; n<difficulty; n++)
    {
        int x = irandom(0, difficulty - 1);
        int y = irandom(0, difficulty - 1);

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

void MineSweeper::onFieldClick(int x, int y)
{
    FieldItem& item = field_item[x][y];
    if (item.button->getValue() || item.button->getText() == "X" || error_count > 1 || correct_count == (difficulty * difficulty - difficulty))
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
        int difficulty = 0;
        if (x > 0 && y > 0 && field_item[x-1][y-1].bomb) difficulty++;
        if (x > 0 && field_item[x-1][y].bomb) difficulty++;
        if (x > 0 && y < difficulty - 1 && field_item[x-1][y+1].bomb) difficulty++;

        if (y > 0 && field_item[x][y-1].bomb) difficulty++;
        if (y < difficulty - 1 && field_item[x][y+1].bomb) difficulty++;

        if (x < difficulty - 1 && y > 0 && field_item[x+1][y-1].bomb) difficulty++;
        if (x < difficulty - 1 && field_item[x+1][y].bomb) difficulty++;
        if (x < difficulty - 1 && y < difficulty - 1 && field_item[x+1][y+1].bomb) difficulty++;

        if (difficulty < 1)
            item.button->setText("");
        else
            item.button->setText(string(difficulty));

        if (difficulty < 1)
        {
            if (x > 0 && y > 0) onFieldClick(x - 1, y - 1);
            if (x > 0)  onFieldClick(x - 1, y);
            if (x > 0 && y < difficulty - 1) onFieldClick(x - 1, y + 1);

            if (y > 0)  onFieldClick(x, y - 1);
            if (y < difficulty - 1)  onFieldClick(x, y + 1);

            if (x < difficulty - 1 && y > 0)  onFieldClick(x + 1, y - 1);
            if (x < difficulty - 1)  onFieldClick(x + 1, y);
            if (x < difficulty - 1 && y < difficulty - 1)  onFieldClick(x + 1, y + 1);
        }
    }

    if (error_count > 1)
    {
        status_label->setText("Hacking FAILED");
        progress_bar->setValue(0.0f);
    }else if (correct_count == (difficulty * difficulty - difficulty))
    {
        gameComplete();
    }else{
        status_label->setText("Hacking in progress: " + string(correct_count * 100 / (difficulty * difficulty - difficulty)) + "%");
        progress_bar->setValue(float(correct_count) / float(difficulty * difficulty - difficulty));
    }
}