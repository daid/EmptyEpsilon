#ifndef GUI_FREQUENCY_CURVE_H
#define GUI_FREQUENCY_CURVE_H

#include "gui/gui2.h"

class GuiFrequencyCurve : public GuiBox
{
    bool frequency_is_beam;
    bool more_damage_is_positive;
    
    int frequency;
public:
    GuiFrequencyCurve(GuiContainer* owner, string id, bool frequency_is_beam, bool more_damage_is_positive);
    
    virtual void onDraw(sf::RenderTarget& window);
    
    void setFrequency(int frequency) { this->frequency = frequency; }
};

#endif//GUI_FREQUENCY_CURVE_H
