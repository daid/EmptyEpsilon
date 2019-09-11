/** An abstract class to present an interface on which to implement (hacking)
 *  minigames. Concrete implementations will need to implement at least their
 *  own constructor and reset() functions, and probably the disable() function.
 *  Calling gameComplete() registers a successful minigame with the owner
 */

#ifndef MINIGAME_H
#define MINIGAME_H

#include <vector>

class GuiButton;
class GuiToggleButton;
class GuiProgressbar;
class GuiLabel;
class GuiHackingDialog;

class MiniGame
{
  public:
    MiniGame(GuiHackingDialog* owner, int difficulty);
    ~MiniGame();

    void setHackingStatusText(string status);
    float getProgress();
    virtual bool isGameComplete();
    virtual sf::Vector2f getBoardSize();

    virtual void reset();
    virtual void disable();

  protected:
    int difficulty;
    bool game_complete;
    GuiPanel* game_panel;
    GuiLabel* status_label;
    GuiLabel* hacking_status_label;
    GuiButton* reset_button;
    GuiButton* close_button;
    GuiProgressbar* progress_bar;
    GuiHackingDialog* parent;
    std::vector<GuiElement*> board;
    void gameComplete();
};

#endif//MINIGAME_H
