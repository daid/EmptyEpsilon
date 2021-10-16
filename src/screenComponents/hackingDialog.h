#ifndef HACKING_DIALOG_H
#define HACKING_DIALOG_H

#include "gui/gui2_overlay.h"
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
    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    void onMiniGameComplete(bool success);

private:
    P<SpaceObject> target;
    string target_system;
    string locale_target_system;
    float reset_time;
    static constexpr float auto_reset_time = 2.0f;
    bool last_game_success;
    GuiLabel* status_label;
    GuiLabel* hacking_status_label;
    GuiButton* reset_button;
    GuiButton* close_button;
    GuiProgressbar* progress_bar;

    GuiPanel* minigame_box;
    std::shared_ptr<MiniGame> game;
    GuiPanel* target_selection_box;
    GuiListbox* target_list;
    void getNewGame();
};

#endif//HACKING_DIALOG_H
