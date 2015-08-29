#include "playerInfo.h"
#include "helmsScreen.h"

#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"

HelmsScreen::HelmsScreen(GuiContainer* owner)
: GuiOverlay(owner, "HELMS_SCREEN", sf::Color::Black)
{
    GuiRadarView* radar = new GuiRadarView(this, "HELMS_RADAR", 5000.0, nullptr);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            if (my_spaceship)
            {
                float angle = sf::vector2ToAngle(position - my_spaceship->getPosition());
                heading_hint->setText(string(fmodf(angle + 90.f + 360.f, 360.f), 1))->setPosition(InputHandler::getMousePos() - sf::Vector2f(0, 50))->show();
                my_spaceship->commandTargetRotation(angle);
            }
        },
        [this](sf::Vector2f position) {
            if (my_spaceship)
            {
                float angle = sf::vector2ToAngle(position - my_spaceship->getPosition());
                heading_hint->setText(string(fmodf(angle + 90.f + 360.f, 360.f), 1))->setPosition(InputHandler::getMousePos() - sf::Vector2f(0, 50))->show();
                my_spaceship->commandTargetRotation(angle);
            }
        },
        [this](sf::Vector2f position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(sf::vector2ToAngle(position - my_spaceship->getPosition()));
            heading_hint->hide();
        }
    );
    
    radar->setJoystickCallbacks(
        [this](float x_position) {
            if (my_spaceship)
            {
                float angle = my_spaceship->getRotation() + x_position;
                //heading_hint->setText(string(fmodf(angle + 90.f + 360.f, 360.f), 1))->setPosition(InputHandler::getMousePos() - sf::Vector2f(0, 50))->show();
                my_spaceship->commandTargetRotation(angle);
            }
        },
        [this](float y_position) {
            if (my_spaceship)
            {
                //float angle = my_spaceship->getRotation() + y_position;
                //heading_hint->setText(string(fmodf(angle + 90.f + 360.f, 360.f), 1))->setPosition(InputHandler::getMousePos() - sf::Vector2f(0, 50))->show();
                //my_spaceship->commandTargetRotation(angle);
            }
        },
        [this](float z_position) {
            if (my_spaceship)
                my_spaceship->commandImpulse(-(z_position / 100));
        });
    heading_hint = new GuiLabel(this, "HEADING_HINT", "", 30);
    heading_hint->setAlignment(ACenter)->setSize(0, 0);

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(this, "HEADING_DISPLAY", 0.45, "Heading", "");
    heading_display->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(this, "VELOCITY_DISPLAY", 0.45, "Speed", "");
    velocity_display->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    
    (new GuiCombatManeuver(this, "COMBAT_MANEUVER"))->setPosition(-50, -50, ABottomRight)->setSize(280, 265);
    
    GuiAutoLayout* engine_layout = new GuiAutoLayout(this, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalLeftToRight);
    engine_layout->setPosition(20, -100, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 300);
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);
    
    (new GuiDockingButton(this, "DOCKING"))->setPosition(20, -20, ABottomLeft)->setSize(280, 50);
}

void HelmsScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1));
        float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(string(velocity, 1) + "km/min");
        
        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);
    }
    GuiOverlay::onDraw(window);
}
