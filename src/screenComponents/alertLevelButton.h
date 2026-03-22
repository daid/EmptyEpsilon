#ifndef ALERT_LEVEL_BUTTON_H
#define ALERT_LEVEL_BUTTON_H

#include "gui/gui2_button.h"
#include "gui/gui2_togglebutton.h"
#include "components/player.h"

class GuiAlertLevelSelect : public GuiElement
{
public:
    GuiAlertLevelSelect(GuiContainer* owner, string id);

    virtual void onUpdate() override;

private:
    std::vector<GuiButton*> alert_level_buttons;
    GuiToggleButton* alert_level_button;
    AlertLevel last_level;
};

#endif//ALERT_LEVEL_BUTTON_H
