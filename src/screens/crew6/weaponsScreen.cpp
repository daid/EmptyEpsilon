#include "playerInfo.h"
#include "weaponsScreen.h"

#include "screenComponents/radarView.h"
#include "screenComponents/missileTubeControls.h"

WeaponsScreen::WeaponsScreen(GuiContainer* owner)
: GuiOverlay(owner, "WEAPONS_SCREEN", sf::Color::Black)
{
    GuiRadarView* radar = new GuiRadarView(this, "HELMS_RADAR", 5000.0);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            
        },
        [this](sf::Vector2f position) {
            
        },
        [this](sf::Vector2f position) {
            
        }
    );

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    
    new GuiMissileTubeControls(this, "MISSILE_TUBES");
}

void WeaponsScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        shields_display->setValue(string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + ":" + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)));
    }
    GuiOverlay::onDraw(window);
}
