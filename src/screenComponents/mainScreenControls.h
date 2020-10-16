#ifndef MAIN_SCREEN_CONTROLS_H
#define MAIN_SCREEN_CONTROLS_H

#include "gui/gui2_autolayout.h"

class GuiToggleButton;
class GuiButton;

class GuiMainScreenControls : public GuiAutoLayout
{
private:
    GuiToggleButton* open_button = nullptr;
    std::vector<GuiButton*> buttons;
    GuiButton* target_lock_button = nullptr;
    GuiButton* tactical_button = nullptr;
    GuiButton* long_range_button = nullptr;
    GuiButton* database_button = nullptr;
    GuiButton* show_comms_button = nullptr;
    GuiButton* hide_comms_button = nullptr;
    bool onscreen_comms_active = false;

    void closePopup();
public:
    GuiMainScreenControls(GuiContainer* owner);
};

#endif//MAIN_SCREEN_CONTROLS_H
