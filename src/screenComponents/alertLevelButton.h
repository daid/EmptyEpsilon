#ifndef ALERT_LEVEL_BUTTON_H
#define ALERT_LEVEL_BUTTON_H

#include "gui/gui2_button.h"

class GuiAlertLevelSelect : public GuiElement
{
public:
    GuiAlertLevelSelect(GuiContainer* owner, string id);

    virtual void onUpdate() override;

private:
    std::vector<GuiButton*> alert_level_buttons;
};

#endif//ALERT_LEVEL_BUTTON_H
