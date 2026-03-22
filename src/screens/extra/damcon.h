#ifndef DAMCON_H
#define DAMCON_H

#include "screens/baseShipScreen.h"
#include "components/shipsystem.h"

class GuiKeyValueDisplay;

class DamageControlScreen : public BaseShipScreen
{
private:
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* system_health[ShipSystem::COUNT];
public:
    DamageControlScreen(GuiContainer* owner);

    void onDraw(sp::RenderTarget& target) override;
};

#endif//DAMCON_H
