#include "mineSweeper.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_panel.h"

MineSweeper::MineSweeper(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
: MiniGame(owner, parent, difficulty) {
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem* item = new FieldItem(owner, "", "", [this, x, y](bool value) { getFieldItem(x, y)->setValue(!value); onFieldClick(x, y); });
            item->setSize(50, 50);
            item->setPosition(x * 50 - difficulty * 25, 25 + y * 50 - difficulty * 25, ACenter);
            board.emplace_back(item);
        }
    }
    reset();
}

void MineSweeper::disable()
{
    MiniGame::disable();
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            FieldItem* item = getFieldItem(x, y);
            item->setText("");
            item->setValue(false);
            item->disable();
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
            item->setText("");
            item->setValue(false);
            item->enable();
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

}

float MineSweeper::getProgress()
{
    return (float)correct_count / (float)(difficulty * difficulty - difficulty);
}

sf::Vector2f MineSweeper::getBoardSize()
{
  return sf::Vector2f(difficulty*50, difficulty*50);
}

void MineSweeper::onFieldClick(int x, int y)
{
    FieldItem* item = getFieldItem(x, y);
    if (item->getValue() || item->getText() == "X" || error_count > 1 || correct_count == (difficulty * difficulty - difficulty))
    {
        //Unpressing an already pressed button.
        return;
    }
    item->setValue(true);
    if (item->bomb)
    {
        item->setText("X");
        item->setValue(false);
        error_count++;
    }else{
        correct_count++;
        int proximity = 0;
        if (x > 0 && y > 0 && getFieldItem(x - 1, y - 1)->bomb) proximity++;
        if (x > 0 && getFieldItem(x - 1, y)->bomb) proximity++;
        if (x > 0 && y < difficulty - 1 && getFieldItem(x - 1, y + 1)->bomb) proximity++;

        if (y > 0 && getFieldItem(x, y - 1)->bomb) proximity++;
        if (y < difficulty - 1 && getFieldItem(x, y + 1)->bomb) proximity++;

        if (x < difficulty - 1 && y > 0 && getFieldItem(x + 1, y - 1)->bomb) proximity++;
        if (x < difficulty - 1 && getFieldItem(x + 1, y)->bomb) proximity++;
        if (x < difficulty - 1 && y < difficulty - 1 && getFieldItem(x + 1, y + 1)->bomb) proximity++;

        if (proximity < 1)
            item->setText("");
        else
            item->setText(string(proximity));

        if (proximity < 1)
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

    if (error_count > 1 || correct_count == (difficulty * difficulty - difficulty))
    {
        gameComplete();
    }
}


MineSweeper::FieldItem* MineSweeper::getFieldItem(int x, int y)
{
    return dynamic_cast<MineSweeper::FieldItem*>(board[x * difficulty + y]);
}

MineSweeper::FieldItem::FieldItem(GuiContainer* owner, string id, string text, func_t func)
: GuiToggleButton(owner, id, text, func), bomb(false)
{
}
