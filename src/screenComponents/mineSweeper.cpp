#include "mineSweeper.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"

MineSweeper::MineSweeper(GuiHackingDialog* owner, string id, int difficulty)
: MiniGame(owner, id, difficulty) {
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem* item = new FieldItem();
            item->button = new GuiToggleButton(this, "", "", [this, x, y](bool value) { getFieldItem(x, y)->button->setValue(!value); onFieldClick(x, y); });
            item->button->setSize(50, 50);
            item->button->setPosition(25 + x * 50, 75 + y * 50);
            board.push_back(item);
        }
    }

    //make buttons smaller for small boards
    if (difficulty < 7)
    {
        reset_button->setSize(difficulty * 50 / 2, 50);
        close_button->setSize(difficulty * 50 / 2, 50);
    }
    reset_button->setPosition(25, 75 + difficulty * 50, ATopLeft);
    close_button->setPosition(-25, 75 + difficulty * 50, ATopRight);
    setSize(50 * difficulty + 100, 50 * difficulty + 145);
}

void MineSweeper::disable()
{
    MiniGame::disable();
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem* item = getFieldItem(x, y);
            item->button->setText("");
            item->button->setValue(false);
            item->button->disable();
        }
    }
}

void MineSweeper::reset()
{
    MiniGame::reset();
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem* item = getFieldItem(x, y);
            item->button->setText("");
            item->button->setValue(false);
            item->button->enable();
            item->bomb = false;
        }
    }
    for(int n=0; n<difficulty; n++)
    {
        int x = irandom(0, difficulty - 1);
        int y = irandom(0, difficulty - 1);

        if (getFieldItem(x, y)->bomb)
        {
            n--;
            continue;
        }
        getFieldItem(x, y)->bomb = true;
    }
    error_count = 0;
    correct_count = 0;

    progress_bar->setValue(0.0f);
    status_label->setText("Hacking in progress: 0%");
}

void MineSweeper::onFieldClick(int x, int y)
{
    FieldItem* item = getFieldItem(x, y);
    if (item->button->getValue() || item->button->getText() == "X" || error_count > 1 || correct_count == (difficulty * difficulty - difficulty))
    {
        //Unpressing an already pressed button.
        return;
    }
    item->button->setValue(true);
    if (item->bomb)
    {
        item->button->setText("X");
        item->button->setValue(false);
        error_count++;
    }else{
        correct_count++;
        int difficulty = 0;
        if (x > 0 && y > 0 && getFieldItem(x - 1, y - 1)->bomb) difficulty++;
        if (x > 0 && getFieldItem(x - 1, y)->bomb) difficulty++;
        if (x > 0 && y < difficulty - 1 && getFieldItem(x - 1, y + 1)->bomb) difficulty++;

        if (y > 0 && getFieldItem(x, y - 1)->bomb) difficulty++;
        if (y < difficulty - 1 && getFieldItem(x, y + 1)->bomb) difficulty++;

        if (x < difficulty - 1 && y > 0 && getFieldItem(x + 1, y - 1)->bomb) difficulty++;
        if (x < difficulty - 1 && getFieldItem(x + 1, y)->bomb) difficulty++;
        if (x < difficulty - 1 && y < difficulty - 1 && getFieldItem(x + 1, y + 1)->bomb) difficulty++;

        if (difficulty < 1)
            item->button->setText("");
        else
            item->button->setText(string(difficulty));

        if (difficulty < 1)
        {
            //if no bombs found in proximity, auto click on all surrounding tiles
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


MineSweeper::FieldItem* MineSweeper::getFieldItem(int x, int y)
{
    return board[x * difficulty + y];
}
