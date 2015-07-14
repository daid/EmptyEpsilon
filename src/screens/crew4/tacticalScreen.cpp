#include "playerInfo.h"
#include "tacticalScreen.h"

#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"

TacticalScreen::TacticalScreen(GuiContainer* owner)
: GuiOverlay(owner, "TACTICAL_SCREEN", sf::Color::Black)
{
    radar = new GuiRadarView(this, "TACTICAL_RADAR", 5000.0, nullptr);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 750);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableTargetProjections()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            targets.setToClosestTo(position, 250);
            if (my_spaceship && targets.get())
                my_spaceship->commandSetTarget(targets.get());
            else if (my_spaceship)
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

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(this, "HEADING_DISPLAY", 0.45, "Heading", "");
    heading_display->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(this, "VELOCITY_DISPLAY", 0.45, "Speed", "");
    velocity_display->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setTextSize(20)->setPosition(20, 220, ATopLeft)->setSize(240, 40);
    
    missile_aim = new GuiRotationDial(this, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
        radar->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    lock_aim = new GuiToggleButton(this, "LOCK_AIM", "Lock", nullptr);
    lock_aim->setPosition(300, 50, ATopCenter)->setSize(130, 50);
    lock_aim->setValue(true);

    GuiAutoLayout* engine_layout = new GuiAutoLayout(this, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalRightToLeft);
    engine_layout->setPosition(-20, -70, ABottomRight)->setSize(GuiElement::GuiSizeMax, 300);
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);

    (new GuiDockingButton(this, "DOCKING"))->setPosition(-20, -70, ABottomRight)->setSize(280, 50);

    //TODO: Fit this somewhere on the already full and chaotic tactical UI...
    //(new GuiCombatManeuver(this, "COMBAT_MANEUVER"))->setPosition(-50, -50, ABottomRight)->setSize(280, 265);
}

void TacticalScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(fmodf(my_spaceship->getRotation() + 360.0 + 360.0 - 270.0, 360.0), 1));
        float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(string(velocity, 1) + "km/min");
        
        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);

        shields_display->setValue(string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "% " + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)) + "%");
        targets.set(my_spaceship->getTarget());
        
        if (lock_aim->getValue())
        {
            missile_aim->setValue(my_spaceship->getRotation());
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
            radar->setMissileTargetAngle(missile_aim->getValue());
        }
    }
    GuiOverlay::onDraw(window);
}
