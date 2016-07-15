#ifndef SHIELD_FREQUENCY_SELECT_H
#define SHIELD_FREQUENCY_SELECT_H

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

#endif//SHIELD_FREQUENCY_SELECT_H
