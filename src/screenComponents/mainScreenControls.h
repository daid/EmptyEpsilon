#ifndef MAIN_SCREEN_CONTROLS_H
#define MAIN_SCREEN_CONTROLS_H

#include "gui/gui2_autolayout.h"

class GuiToggleButton;
class GuiButton;

class GuiMainScreenControls : public GuiAutoLayout
{
private:
    GuiToggleButton* open_button;
    std::vector<GuiButton*> buttons;
    GuiButton* target_lock_button;
    GuiButton* tactical_button;
    GuiButton* long_range_button;
    GuiButton* global_range_button;
    GuiButton* ship_state_button;
    GuiButton* show_comms_button;
    GuiButton* hide_comms_button;
    bool onscreen_comms_active = false;
    
    void closePopup();
public:
    GuiMainScreenControls(GuiContainer* owner);
};

#endif//MAIN_SCREEN_CONTROLS_H
