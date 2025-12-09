#pragma once

#include "miniGame.h"
#include "gui/gui2_togglebutton.h"

class GuiLabel;
class GuiToggleButton;

/** An implementation of mineSweeper for use as a hacking minigame.
 *  Original implementation by https://github.com/daid
 */
class MineSweeper : public MiniGame {
  public:
    MineSweeper(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual ~MineSweeper();
    virtual void reset() override;
    virtual void disable() override;
    virtual float getProgress() override;
    virtual glm::vec2 getBoardSize() override;
  protected:
    virtual void gameComplete() override;
  private:
    void onFieldClick(int x, int y);
    void onFieldRightClick(int x, int y);
    void updateAttemptsLabel();
    int error_count;
    int correct_count;
    int field_size;
    int bomb_count;
    GuiLabel* attempts_label;
    GuiToggleButton* flag_mode_toggle;
    bool flag_mode;
    class FieldItem : public GuiToggleButton
    {
    public:
        FieldItem(GuiContainer* owner, string id, string text, func_t left_func, func_t right_func);

        virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
        virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

        bool bomb;

    private:
        func_t left_click_func;
        func_t right_click_func;
        sp::io::Pointer::Button last_button;
    };
    FieldItem* getFieldItem(int x, int y);
};
