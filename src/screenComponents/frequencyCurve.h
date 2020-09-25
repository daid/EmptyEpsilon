#ifndef FREQUENCY_CURVE_H
#define FREQUENCY_CURVE_H

#include "gui/gui2_panel.h"

class GuiFrequencyCurve : public GuiPanel
{
    bool frequency_is_beam;
    bool more_damage_is_positive;

    int frequency;
public:
    GuiFrequencyCurve(GuiContainer* owner, string id, bool frequency_is_beam, bool more_damage_is_positive);

    virtual void onDraw(sf::RenderTarget& window);

    GuiFrequencyCurve* setFrequency(int frequency) { this->frequency = frequency; return this; }
};

#endif//FREQUENCY_CURVE_H
