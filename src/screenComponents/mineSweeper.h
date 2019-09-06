/** An implementation of mineSweeper for use as a hacking minigame.
 *  Original implementation by https://github.com/daid
 */

#ifndef MINESWEEPER_H
#define MINESWEEPER_H

#include "miniGame.h"
#include <vector>
#include <memory>


class MineSweeper : public MiniGame {
  public:
    MineSweeper(GuiHackingDialog* owner, string id, int difficulty);
    virtual void reset();
    virtual void disable();
  private:
    void onFieldClick(int x, int y);
    int error_count;
    int correct_count;
    class FieldItem
    {
    public:
        GuiToggleButton *button;
        bool bomb;
    };
    std::vector<FieldItem*> board;
    FieldItem* getFieldItem(int x, int y);
};

#endif//MINESWEEPER_H
