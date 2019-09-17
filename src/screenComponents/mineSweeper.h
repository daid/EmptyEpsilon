/** An implementation of mineSweeper for use as a hacking minigame.
 *  Original implementation by https://github.com/daid
 */

#ifndef MINESWEEPER_H
#define MINESWEEPER_H

#include "miniGame.h"
#include "gui/gui2_togglebutton.h"
#include <vector>


class MineSweeper : public MiniGame {
  public:
    MineSweeper(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual void reset() override;
    virtual void disable() override;
    virtual float getProgress() override;
    virtual sf::Vector2f getBoardSize() override;
  private:
    void onFieldClick(int x, int y);
    int error_count;
    int correct_count;
    int field_size;
    class FieldItem : public GuiToggleButton
    {
    public:
        FieldItem(GuiContainer* owner, string id, string text, func_t func);

        bool bomb;
    };
    FieldItem* getFieldItem(int x, int y);
};

#endif//MINESWEEPER_H
