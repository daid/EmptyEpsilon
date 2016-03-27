#include "damcon.h"

#include "playerInfo.h"
#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shipInternalView.h"

DamageControlScreen::DamageControlScreen(GuiContainer* owner)
: GuiOverlay(owner, "DAMCON_SCREEN", colorConfig.background)
{
    (new GuiShipInternalView(this, "SHIP_INTERNAL_VIEW", 48.0f * 1.5f))->setShip(my_spaceship)->setPosition(300, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    GuiAutoLayout* system_health_layout = new GuiAutoLayout(this, "DAMCON_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    system_health_layout->setPosition(0, 0, ACenterLeft)->setSize(300, 600);

    hull_display = new GuiKeyValueDisplay(system_health_layout, "HULL", 0.8, "Hull", "0%");
    hull_display->setSize(GuiElement::GuiSizeMax, 40);

    for(unsigned int n=0; n<SYS_COUNT; n++)
    {
        system_health[n] = new GuiKeyValueDisplay(system_health_layout, "DAMCON_HEALTH_" + string(n), 0.8, getSystemName(ESystem(n)), "0%");
        system_health[n]->setSize(GuiElement::GuiSizeMax, 40);
    }
    
    (new GuiShieldFrequencySelect(this, "SHIELD_FREQ"))->setPosition(-20, -20, ABottomRight)->setSize(320, 100);
}

void DamageControlScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
    
    if (my_spaceship)
    {
        hull_display->setValue(string(int(100 * my_spaceship->hull_strength / my_spaceship->hull_max)) + "%");
        if (my_spaceship->hull_strength < my_spaceship->hull_max / 4.0f)
            hull_display->setColor(sf::Color::Red);
        else
            hull_display->setColor(sf::Color::White);

        for(unsigned int n=0; n<SYS_COUNT; n++)
        {
            system_health[n]->setVisible(my_spaceship->hasSystem(ESystem(n)));
            system_health[n]->setValue(string(int(my_spaceship->systems[n].health * 100)) + "%");
            if (my_spaceship->systems[n].health < 0)
                system_health[n]->setColor(sf::Color::Red);
            else
                system_health[n]->setColor(sf::Color::White);
        }
    }
}
