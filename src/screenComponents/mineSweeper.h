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
    MineSweeper(GuiHackingDialog* owner, int difficulty);
    ~MineSweeper();
    virtual void reset();
    virtual void disable();
    virtual float getProgress();
    virtual sf::Vector2f getBoardSize();
  private:
    void onFieldClick(int x, int y);
    int error_count;
    int correct_count;
    class FieldItem : public GuiToggleButton
    {
    public:
        FieldItem(GuiContainer* owner, string id, string text, func_t func);

        bool bomb;
    };
    FieldItem* getFieldItem(int x, int y);
};

#endif//MINESWEEPER_H
