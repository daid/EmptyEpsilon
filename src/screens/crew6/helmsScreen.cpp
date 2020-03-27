#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "helmsScreen.h"
#include "preferenceManager.h"

#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_autolayout.h"

HelmsScreen::HelmsScreen(GuiContainer* owner)
: GuiOverlay(owner, "HELMS_SCREEN", colorConfig.background)
{
    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(this, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradient");

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    GuiRadarView* radar = new GuiRadarView(this, "HELMS_RADAR", my_spaceship->getShortRangeRadarRange(), nullptr);
    
    combat_maneuver = new GuiCombatManeuver(this, "COMBAT_MANEUVER");
    combat_maneuver->setPosition(-20, -20, ABottomRight)->setSize(280, 215);
    
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->enableMissileTubeIndicators();
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
    radar->setAutoRotating(PreferencesManager::get("helms_radar_lock","0")=="1");
    
    heading_hint = new GuiLabel(this, "HEADING_HINT", "", 30);
    heading_hint->setAlignment(ACenter)->setSize(0, 0);

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(this, "HEADING_DISPLAY", 0.45, tr("Heading"), "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(this, "VELOCITY_DISPLAY", 0.45, tr("Speed"), "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    
    GuiAutoLayout* engine_layout = new GuiAutoLayout(this, "ENGINE_LAYOUT", GuiAutoLayout::LayoutHorizontalLeftToRight);
    engine_layout->setPosition(20, -100, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 300);
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);
    
    (new GuiDockingButton(this, "DOCKING"))->setPosition(20, -20, ABottomLeft)->setSize(280, 50);

    (new GuiCustomShipFunctions(this, helmsOfficer, ""))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void HelmsScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(my_spaceship->getHeading(), 1));
        float velocity = sf::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(tr("{value} {unit}/min").format({{"value", string(velocity, 1)}, {"unit", DISTANCE_UNIT_1K}}));
        
        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);
    }
    GuiOverlay::onDraw(window);
}

bool HelmsScreen::onJoystickAxis(const AxisAction& axisAction){
    if(my_spaceship){
        if (axisAction.category == "HELMS"){
            if (axisAction.action == "IMPULSE"){
                my_spaceship->commandImpulse(axisAction.value);  
                return true;
            } 
            if (axisAction.action == "ROTATE"){
                my_spaceship->commandTurnSpeed(axisAction.value);
                return true;
            } 
            if (axisAction.action == "STRAFE"){
                my_spaceship->commandCombatManeuverStrafe(axisAction.value);
                return true;
            } 
            if (axisAction.action == "BOOST"){
                my_spaceship->commandCombatManeuverBoost(axisAction.value);
                return true;
            }
        }
    }
    return false;
}

void HelmsScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "HELMS" && my_spaceship)
    {
        if (key.hotkey == "TURN_LEFT")
            my_spaceship->commandTargetRotation(my_spaceship->getRotation() - 5.0f);
        else if (key.hotkey == "TURN_RIGHT")
            my_spaceship->commandTargetRotation(my_spaceship->getRotation() + 5.0f);
    }
}
