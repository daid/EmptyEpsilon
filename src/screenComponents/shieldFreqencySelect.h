#ifndef GUI_SHIELD_FREQUENCY_SELECT_H
#define GUI_SHIELD_FREQUENCY_SELECT_H

#include "gui/gui2.h"

class GuiShieldFrequencySelect : public GuiBox
{
private:
    GuiLabel* current_frequency;
    GuiSelector* new_frequency;
    GuiButton* calibrate_button;
    GuiProgressbar* calibrate_progressbar;
public:
    GuiShieldFrequencySelect(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SHIELD_FREQUENCY_SELECT_H
