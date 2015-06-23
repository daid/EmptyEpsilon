#ifndef GUI_POWER_DAMAGE_INDICATOR_H
#define GUI_POWER_DAMAGE_INDICATOR_H

#include "gui/gui2.h"
#include "shipTemplate.h"

class GuiPowerDamageIndicator : public GuiElement
{
private:
    ESystem system;
    float text_size;
public:
    GuiPowerDamageIndicator(GuiContainer* owner, string name, ESystem system);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_POWER_DAMAGE_INDICATOR_H
