#ifndef FREQUENCY_CURVE_H
#define FREQUENCY_CURVE_H

#include "gui/gui2_panel.h"

class GuiFrequencyCurve : public GuiPanel
{
    bool frequency_is_beam;
    bool more_damage_is_positive;
    bool enemy_without_equipment;   /*< If target ship have beams/shields (depending on frequency_is_beam) */

    int frequency;
public:
    GuiFrequencyCurve(GuiContainer* owner, string id, bool frequency_is_beam, bool more_damage_is_positive);

    virtual void onDraw(sf::RenderTarget& window);

    GuiFrequencyCurve* setFrequency(int frequency) { this->frequency = frequency; return this; }

    void setEnemyWithoutEquipment(bool state) { this->enemy_without_equipment = state; }
};

#endif//FREQUENCY_CURVE_H
