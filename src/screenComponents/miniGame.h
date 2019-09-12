/** An abstract class to present an interface on which to implement (hacking)
 *  minigames. Concrete implementations will need to implement at least their
 *  own constructor and reset() functions, and probably the disable() function.
 *  Calling gameComplete() registers a successful minigame with the owner
 */

#ifndef MINIGAME_H
#define MINIGAME_H

#include <vector>
#include "hackingDialog.h"

class GuiButton;
class GuiToggleButton;
class GuiProgressbar;
class GuiLabel;
class GuiPanel;

class MiniGame
{
  public:
    MiniGame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual ~MiniGame();

    virtual float getProgress();
    virtual bool isGameComplete();
    virtual sf::Vector2f getBoardSize();

    virtual void reset();
    virtual void disable();

  protected:
    int difficulty;
    GuiHackingDialog* parent;
    bool game_complete;
    std::vector<GuiElement*> board;
    void gameComplete();
};

#endif//MINIGAME_H
