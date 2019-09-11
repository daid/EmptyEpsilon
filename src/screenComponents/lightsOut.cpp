#include "lightsOut.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"

LightsOut::LightsOut(GuiHackingDialog* owner, int difficulty)
: MiniGame(owner, difficulty) {
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            board.emplace_back(new LightsOutToggleButton(owner, "", "", [this, x, y](bool value) {onFieldClick(x, y); } ));
            board.back()->setSize(50, 50);
            board.back()->setPosition(25 + x * 50, 75 + y * 50);
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
    progress_bar->setSize(50 * difficulty, 50);
}

void LightsOut::disable()
{
    MiniGame::disable();
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            getField(x, y)->disable();
        }
    }
}

void LightsOut::reset()
{
    MiniGame::reset();
    //generate solved configuration
    lights_on = difficulty*difficulty;
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            LightsOut::LightsOutToggleButton* item = getField(x, y);
            item->setText("");
            item->setValue(true);
            item->enable();
        }
    }
    //make sure we don't have a solved board by accident
    while (lights_on == difficulty*difficulty)
    {
        //Mess the solved board up with n moves
        int number_moves = irandom(3, 3*difficulty);
        for (int i=0; i<number_moves; i++)
        {
            int x=irandom(0, difficulty-1);
            int y=irandom(0, difficulty-1);
            getField(x, y)->setValue(!(getField(x, y)->getValue()));
            toggle(x, y);
        }
    }
    progress_bar->setValue((float) lights_on / (float) (difficulty*difficulty));
    status_label->setText("Hacking in progress: "+string(100*lights_on/(difficulty*difficulty)) + "%");
}

float LightsOut::getProgress()
{
  return (float) lights_on / (float) (difficulty*difficulty);
}


sf::Vector2f LightsOut::getBoardSize()
{
  return sf::Vector2f(difficulty*50, difficulty*50);
}


void LightsOut::onFieldClick(int x, int y)
{
    toggle(x, y);

    if (lights_on == difficulty*difficulty)
    {
        gameComplete();
    }
}

void LightsOut::toggle(int x, int y)
{
    //field itself is already toggled, only need to get Value
    lights_on += getField(x, y)->getValue() ? 1 : -1;
    if (x > 0) {
      lights_on += getField(x - 1, y)->toggle() ? 1 : -1;
    }
    if (x < difficulty - 1) {
      lights_on += getField(x + 1, y)->toggle() ? 1 : -1;
    }
    if (y > 0) {
      lights_on += getField(x, y - 1)->toggle() ? 1 : -1;
    }
    if (y < difficulty - 1) {
      lights_on += getField(x, y + 1)->toggle() ? 1 : -1;
    }
}

LightsOut::LightsOutToggleButton* LightsOut::getField(int x, int y)
{
    return dynamic_cast<LightsOut::LightsOutToggleButton*> (board[x * difficulty + y]);
}

bool LightsOut::LightsOutToggleButton::toggle()
{
    bool value = !getValue();
    setValue(value);
    return value;
}

LightsOut::LightsOutToggleButton::LightsOutToggleButton(GuiContainer* owner, string id, string text, func_t func) : GuiToggleButton(owner, id, text, func)
{

}
