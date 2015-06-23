#include "playerInfo.h"
#include "helmsScreen.h"

#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"

HelmsScreen::HelmsScreen(GuiContainer* owner)
: GuiOverlay(owner, "HELMS_SCREEN", sf::Color::Black)
{
    GuiRadarView* radar = new GuiRadarView(this, "HELMS_RADAR", 5000.0);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
        },
        [this](sf::Vector2f position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
        },
        [this](sf::Vector2f position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
        }
    );
    
    (new GuiCombatManeuver(this, "COMBAT_MANEUVER"))->setPosition(-50, -50, ABottomRight)->setSize(280, 265);
}

void HelmsScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
}
