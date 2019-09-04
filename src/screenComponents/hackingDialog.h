#ifndef HACKING_DIALOG_H
#define HACKING_DIALOG_H

#include "gui/gui2_overlay.h"
#include "miniGame.h"
#include <memory>

class GuiPanel;
class GuiLabel;
class GuiListbox;
class GuiButton;
class GuiToggleButton;
class GuiProgressbar;
class SpaceObject;
class MiniGame;

class GuiHackingDialog : public GuiOverlay
{
public:
    GuiHackingDialog(GuiContainer* owner, string id);

    void open(P<SpaceObject> target);
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
    void miniGameComplete();
private:
    P<SpaceObject> target;
    string target_system;
    float reset_time;
    static constexpr float auto_reset_time = 2.0f;


    MiniGame* minigame_box;
    GuiPanel* target_selection_box;
    GuiListbox* target_list;
    void getNewGame(bool sameType = false);
};

#endif//HACKING_DIALOG_H
