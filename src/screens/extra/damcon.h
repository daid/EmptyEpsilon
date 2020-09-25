#ifndef DAMCON_H
#define DAMCON_H

#include "gui/gui2_overlay.h"
#include "shipTemplate.h"

class GuiKeyValueDisplay;

class DamageControlScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* system_health[SYS_COUNT];
public:
    DamageControlScreen(GuiContainer* owner);

    void onDraw(sf::RenderTarget& window) override;
};

#endif//DAMCON_H
