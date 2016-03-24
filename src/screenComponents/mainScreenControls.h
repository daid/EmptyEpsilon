#ifndef MAIN_SCREEN_CONTROLS_H
#define MAIN_SCREEN_CONTROLS_H

#include "gui/gui2.h"

class GuiMainScreenControls : public GuiAutoLayout
{
private:
    GuiToggleButton* open_button;
    std::vector<GuiButton*> buttons;
    GuiButton* tactical_button;
    GuiButton* long_range_button;
public:
    GuiMainScreenControls(GuiContainer* owner);
};

#endif//MAIN_SCREEN_CONTROLS_H
