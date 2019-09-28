#include "lightsOut.h"
#include "miniGame.h"
#include "hackingDialog.h"
#include "gui/gui2_panel.h"


LightsOut::LightsOut(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
: MiniGame(owner, parent, difficulty) {
    grid_size = difficulty * 2 + 3;
    for(int x=0; x<grid_size; x++)
    {
        for(int y=0; y<grid_size; y++)
        {
            board.emplace_back(new LightsOutToggleButton(owner, "", "", [this, x, y](bool value) {onFieldClick(x, y); } ));
            board.back()->setSize(50, 50);
            board.back()->setPosition(x * 50 - grid_size * 25, 25 + y * 50 - grid_size * 25, ACenter);
        }
    }
    reset();
}

void LightsOut::disable()
{
    MiniGame::disable();
    for(int x=0; x<grid_size; x++)
    {
        for(int y=0; y<grid_size; y++)
        {
            getField(x, y)->disable();
        }
    }
}

void LightsOut::reset()
{
    MiniGame::reset();
    //generate solved configuration
    lights_on = grid_size*grid_size;
    for(int x=0; x<grid_size; x++)
    {
        for(int y=0; y<grid_size; y++)
        {
            LightsOut::LightsOutToggleButton* item = getField(x, y);
            item->setValue(true);
            item->enable();
        }
    }
    //make sure we don't have a solved board by accident
    while (lights_on == grid_size*grid_size)
    {
        //Mess the solved board up with n moves
        int number_moves = irandom(3, 3*grid_size);
        for (int i=0; i<number_moves; i++)
        {
            int x=irandom(0, grid_size-1);
            int y=irandom(0, grid_size-1);
            getField(x, y)->setValue(!(getField(x, y)->getValue()));
            toggle(x, y);
        }
    }
}

float LightsOut::getProgress()
{
  return ((float) lights_on) / ((float) (grid_size*grid_size));
}


sf::Vector2f LightsOut::getBoardSize()
{
  return sf::Vector2f(grid_size*50, grid_size*50);
}


void LightsOut::onFieldClick(int x, int y)
{
    toggle(x, y);

    if (lights_on == grid_size*grid_size)
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
    if (x < grid_size - 1) {
      lights_on += getField(x + 1, y)->toggle() ? 1 : -1;
    }
    if (y > 0) {
      lights_on += getField(x, y - 1)->toggle() ? 1 : -1;
    }
    if (y < grid_size - 1) {
      lights_on += getField(x, y + 1)->toggle() ? 1 : -1;
    }
}

LightsOut::LightsOutToggleButton* LightsOut::getField(int x, int y)
{
    return dynamic_cast<LightsOut::LightsOutToggleButton*> (board[x * grid_size + y]);
}

LightsOut::LightsOutToggleButton::LightsOutToggleButton(GuiContainer* owner, string id, string text, func_t func) : GuiToggleButton(owner, id, text, func)
{

}

bool LightsOut::LightsOutToggleButton::toggle()
{
    bool value = !getValue();
    setValue(value);
    return value;
}
