#ifndef MINIGAME_H
#define MINIGAME_H

#include "gui/gui2_panel.h"

class GuiContainer;
class GuiButton;
class GuiToggleButton;
class GuiProgressbar;
class GuiLabel;
class GuiHackingDialog;

class MiniGame : public GuiPanel
{
  public:
    MiniGame(GuiHackingDialog* owner, string id, int difficulty);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
    void setHackingStatusText(string status);
    void setProgress(float progress);
    virtual void reset();
    virtual bool isGameComplete();
    virtual void disable();

  private:
    int difficulty;
    static constexpr float auto_reset_time = 2.0f;
    int error_count;
    int correct_count;
    bool game_complete;
    class FieldItem
    {
    public:
        GuiToggleButton* button;
        bool bomb;
    };

    FieldItem** field_item;
    GuiLabel* status_label;
    GuiLabel* hacking_status_label;
    GuiButton* reset_button;
    GuiProgressbar* progress_bar;
    GuiHackingDialog* parent;
    void onFieldClick(int x, int y);
    void gameComplete();
}

#endif//MINIGAME_H