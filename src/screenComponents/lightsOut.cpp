#include "lightsOut.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"

LightsOut::LightsOut(GuiHackingDialog* owner, string id, int difficulty)
: MiniGame(owner, id, difficulty) {
    field_item = new LightsOutToggleButton**[difficulty];
    for(int x=0; x<difficulty; x++)
    {
        field_item[x] = new LightsOutToggleButton*[difficulty];
        for(int y=0; y<difficulty; y++)
        {
            field_item[x][y] = new LightsOutToggleButton(this, "", "", [this, x, y](bool value) {onFieldClick(x, y); } );
            field_item[x][y]->setSize(50, 50);
            field_item[x][y]->setPosition(25 + x * 50, 75 + y * 50);
        }
    }
    if (difficulty < 7)
    {
        reset_button->setSize(difficulty * 50 / 2, 50);
        close_button->setSize(difficulty * 50 / 2, 50);
    }
    reset_button->setPosition(25, 75 + difficulty * 50, ATopLeft);
    close_button->setPosition(-25, 75 + difficulty * 50, ATopRight);
}

void LightsOut::disable()
{
    MiniGame::disable();
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            GuiToggleButton* item = field_item[x][y];
            item->disable();
        }
    }
}

void LightsOut::reset()
{
    game_complete = false;
    //generate solved configuration
    lights_on = difficulty*difficulty;
    for(int x=0; x<difficulty; x++)
    {
        for(int y=0; y<difficulty; y++)
        {
            GuiToggleButton* item = field_item[x][y];
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
            toggle(x,y);
        }
    }
    progress_bar->setValue((float) lights_on / (float) (difficulty*difficulty));
    status_label->setText("Hacking in progress: "+string(100*lights_on/(difficulty*difficulty)) + "%");
    reset_button->enable();
}

void LightsOut::onFieldClick(int x, int y)
{
    toggle(x,y);

    if (lights_on == difficulty*difficulty)
    {
        gameComplete();
    }else{
        status_label->setText("Hacking in progress: " + string(100*lights_on/(difficulty*difficulty)) + "%");
        progress_bar->setValue((float) lights_on / (float) (difficulty*difficulty));
    }
}

void LightsOut::toggle(int x, int y)
{
    //field itself is already toggled, only need to get Value
    lights_on += field_item[x][y]->getValue() ? 1 : -1;
    if (x > 0) {
      lights_on += field_item[x-1][y]->toggle() ? 1 : -1;
    }
    if (x < difficulty-1) {
      lights_on += field_item[x+1][y]->toggle() ? 1 : -1;
    }
    if (y > 0) {
      lights_on += field_item[x][y-1]->toggle() ? 1 : -1;
    }
    if (y < difficulty-1) {
      lights_on += field_item[x][y+1]->toggle() ? 1 : -1;
    }
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