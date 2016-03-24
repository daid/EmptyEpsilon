#ifndef GUI_POWER_DAMAGE_INDICATOR_H
#define GUI_POWER_DAMAGE_INDICATOR_H

#include "gui/gui2.h"
#include "shipTemplate.h"

class GuiPowerDamageIndicator : public GuiElement
{
public:
    GuiPowerDamageIndicator(GuiContainer* owner, string name, ESystem system, EGuiAlign icon_align);
    
    virtual void onDraw(sf::RenderTarget& window);

private:
    ESystem system;
    float text_size;
    EGuiAlign icon_align;
    
    sf::Vector2f icon_position;
    sf::Vector2f icon_offset;
    float icon_size;
    
    void drawIcon(sf::RenderTarget& window, string icon_name, sf::Color color);
};

#endif//GUI_POWER_DAMAGE_INDICATOR_H
