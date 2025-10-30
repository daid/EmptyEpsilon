#pragma once

#include "gui/gui2_element.h"

class GuiToggleButton;
class GuiButton;
class GuiPanel;

class GuiMainScreenControls : public GuiElement
{
private:
    GuiPanel* button_strip;
    GuiToggleButton* open_button;
    std::vector<GuiToggleButton*> buttons;
    GuiToggleButton* front_button;
    GuiToggleButton* back_button;
    GuiToggleButton* left_button;
    GuiToggleButton* right_button;
    GuiToggleButton* target_lock_button;
    GuiToggleButton* tactical_button;
    GuiToggleButton* long_range_button;
    GuiToggleButton* strategic_map_button;
    GuiToggleButton* show_comms_button;
    bool onscreen_comms_active;

    void closePopup();
public:
    GuiMainScreenControls(GuiContainer* owner);
};
