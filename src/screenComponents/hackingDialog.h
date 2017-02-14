#ifndef HACKING_DIALOG_H
#define HACKING_DIALOG_H

#include "gui/gui2_overlay.h"

class GuiPanel;
class GuiLabel;
class GuiListbox;
class GuiButton;
class GuiToggleButton;
class GuiProgressbar;
class SpaceObject;

class GuiHackingDialog : public GuiOverlay
{
public:
    GuiHackingDialog(GuiContainer* owner, string id);

    void open(P<SpaceObject> target);
    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
private:
    P<SpaceObject> target;
    string target_system;
    
    static constexpr int hacking_field_size = 8;
    static constexpr int bomb_count = 8;
    static constexpr float auto_reset_time = 2.0f;
    GuiPanel* minigame_box;
    GuiLabel* status_label;
    GuiLabel* hacking_status_label;
    GuiButton* reset_button;
    GuiProgressbar* progress_bar;
    int error_count;
    int correct_count;
    float reset_time;
    class FieldItem
    {
    public:
        GuiToggleButton* button;
        bool bomb;
    };
    FieldItem field_item[hacking_field_size][hacking_field_size];
    
    GuiPanel* target_selection_box;
    GuiListbox* target_list;

    void resetMinigame();
    void disableMinigame();
    void onFieldClick(int x, int y);
};

#endif//HACKING_DIALOG_H
