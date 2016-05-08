#ifndef GUI_SHIELD_FREQUENCY_SELECT_H
#define GUI_SHIELD_FREQUENCY_SELECT_H

#include "gui/gui2_element.h"

class GuiKeyValueDisplay;
class GuiSelector;
class GuiButton;
class GuiProgressbar;

class GuiShieldFrequencySelect : public GuiElement
{
private:
    GuiSelector* new_frequency;
    GuiButton* calibrate_button;
public:
    GuiShieldFrequencySelect(GuiContainer* owner, string id);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_SHIELD_FREQUENCY_SELECT_H
