#ifndef POWER_DAMAGE_INDICATOR_H
#define POWER_DAMAGE_INDICATOR_H

#include "gui/gui2_element.h"
#include "shipTemplate.h"
#include "spaceObjects/playerSpaceship.h"

class GuiPowerDamageIndicator : public GuiElement
{
public:
    GuiPowerDamageIndicator(GuiContainer* owner, string name, ESystem system, EGuiAlign icon_align, P<PlayerSpaceship>& targetSpaceship);
    
    virtual void onDraw(sf::RenderTarget& window);

private:
    ESystem system;
    float text_size;
    EGuiAlign icon_align;
    P<PlayerSpaceship>& target_spaceship;

    sf::Vector2f icon_position;
    sf::Vector2f icon_offset;
    float icon_size;
    
    void drawIcon(sf::RenderTarget& window, string icon_name, sf::Color color);
};

#endif//POWER_DAMAGE_INDICATOR_H
