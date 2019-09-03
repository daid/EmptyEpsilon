/** An abstract class to present an interface on which to implement (hacking)
 *  minigames. Concrete implementations will need to implement at least their
 *  own constructor and reset() functions, and probably the disable() function.
 *  Calling gameComplete() registers a successful minigame with the owner
 */

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

    virtual bool onMouseDown(sf::Vector2f position) override;
    void setHackingStatusText(string status);
    void setProgress(float progress);
    virtual bool isGameComplete();

    virtual void reset() = 0;
    virtual void disable();

  protected:
    int difficulty;
    bool game_complete;

    GuiLabel* status_label;
    GuiLabel* hacking_status_label;
    GuiButton* reset_button;
    GuiButton* close_button;
    GuiProgressbar* progress_bar;
    GuiHackingDialog* parent;
    void gameComplete();
};

#endif//MINIGAME_H
