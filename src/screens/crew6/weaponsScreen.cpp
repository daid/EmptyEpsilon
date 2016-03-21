#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "weaponsScreen.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"

WeaponsScreen::WeaponsScreen(GuiContainer* owner)
: GuiOverlay(owner, "WEAPONS_SCREEN", colorConfig.background)
{
    (new GuiOverlay(this, "", sf::Color::White))->setTextureCenter("gui/BackgroundGradient");
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    radar = new GuiRadarView(this, "HELMS_RADAR", 5000.0, &targets);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableTargetProjections()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (my_spaceship && targets.get())
                my_spaceship->commandSetTarget(targets.get());
        }, nullptr, nullptr
    );
    missile_aim = new GuiRotationDial(this, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
        radar->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 850);
    
    lock_aim = new GuiToggleButton(this, "LOCK_AIM", "Lock", nullptr);
    lock_aim->setPosition(300, 50, ATopCenter)->setSize(130, 50);
    lock_aim->setValue(true);
    
    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        GuiElement* beam_info_box = new GuiElement(this, "BEAM_INFO_BOX");
        beam_info_box->setPosition(-20, -70, ABottomRight)->setSize(270, 150);
        (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", "Beam info", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        (new GuiBeamFrequencySelector(beam_info_box, "BEAM_FREQUENCY_SELECTOR"))->setPosition(0, -50, ABottomRight)->setSize(GuiElement::GuiSizeMax, 50);
        (new GuiBeamTargetSelector(beam_info_box, "BEAM_TARGET_SELECTOR"))->setPosition(0, 0, ABottomRight)->setSize(GuiElement::GuiSizeMax, 50);
    }

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    front_shield_display = new GuiKeyValueDisplay(this, "FRONT_SHIELD_DISPLAY", 0.45, "Front", "");
    front_shield_display->setIcon("gui/icons/shields")->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    rear_shield_display = new GuiKeyValueDisplay(this, "REAR_SHIELD_DISPLAY", 0.45, "Rear", "");
    rear_shield_display->setIcon("gui/icons/shields")->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    
    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    
    (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(-20, -20, ABottomRight)->setSize(280, 50);
}

void WeaponsScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        front_shield_display->setValue(string(my_spaceship->getShieldPercentage(0)) + "%");
        rear_shield_display->setValue(string(my_spaceship->getShieldPercentage(1)) + "%");
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
