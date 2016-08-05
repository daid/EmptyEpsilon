#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "weaponsScreen.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/aimLock.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"
#include "screenComponents/powerDamageIndicator.h"
#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/alertOverlay.h"

#include "gui/gui2_rotationdial.h"
#include "gui/gui2_label.h"
#include "gui/gui2_keyvaluedisplay.h"

WeaponsScreen::WeaponsScreen(GuiContainer* owner)
: GuiOverlay(owner, "WEAPONS_SCREEN", colorConfig.background)
{
    // Render the radar shadow and background decorations.
    background_gradient = new GuiOverlay(this, "BACKGROUND_GRADIENT", sf::Color::White);
    background_gradient->setTextureCenter("gui/BackgroundGradient");

    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    radar = new GuiRadarView(this, "HELMS_RADAR", 5000.0, &targets);
    radar->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->setCallbacks(
        [this](sf::Vector2f position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (my_spaceship && targets.get())
                my_spaceship->commandSetTarget(targets.get());
            else if (my_spaceship)
                my_spaceship->commandSetTarget(NULL);
        }, nullptr, nullptr
    );
    missile_aim = new GuiRotationDial(this, "MISSILE_AIM", -90, 360 - 90, 0, [this](float value){
        tube_controls->setMissileTargetAngle(value);
    });
    missile_aim->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, 850);

    tube_controls = new GuiMissileTubeControls(this, "MISSILE_TUBES");
    tube_controls->setPosition(20, -20, ABottomLeft);
    radar->enableTargetProjections(tube_controls);

    lock_aim = new AimLockButton(this, "LOCK_AIM", tube_controls, missile_aim);
    lock_aim->setPosition(250, 20, ATopCenter)->setSize(130, 50);

    if (gameGlobalInfo->use_beam_shield_frequencies || gameGlobalInfo->use_system_damage)
    {
        GuiElement* beam_info_box = new GuiElement(this, "BEAM_INFO_BOX");
        beam_info_box->setPosition(-20, -120, ABottomRight)->setSize(280, 150);
        (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", "Beam info", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        (new GuiPowerDamageIndicator(beam_info_box, "", SYS_BeamWeapons, ACenterLeft))->setSize(GuiElement::GuiSizeMax, 50);
        (new GuiBeamFrequencySelector(beam_info_box, "BEAM_FREQUENCY_SELECTOR"))->setPosition(0, 0, ABottomRight)->setSize(GuiElement::GuiSizeMax, 50);
        (new GuiBeamTargetSelector(beam_info_box, "BEAM_TARGET_SELECTOR"))->setPosition(0, -50, ABottomRight)->setSize(GuiElement::GuiSizeMax, 50);

        if (!gameGlobalInfo->use_beam_shield_frequencies)
        {   //If we do have system damage, but no shield frequencies, we can partially overlap this with the shield button.
            //So move the beam configuration a bit down.
            beam_info_box->setPosition(-20, -50, ABottomRight);
        }
    }

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    front_shield_display = new GuiKeyValueDisplay(this, "FRONT_SHIELD_DISPLAY", 0.45, "Front", "");
    front_shield_display->setIcon("gui/icons/shields-fore")->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    rear_shield_display = new GuiKeyValueDisplay(this, "REAR_SHIELD_DISPLAY", 0.45, "Rear", "");
    rear_shield_display->setIcon("gui/icons/shields-aft")->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);

    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        //The shield frequency selection includes a shield enable button.
        (new GuiShieldFrequencySelect(this, "SHIELD_FREQ"))->setPosition(-20, -20, ABottomRight)->setSize(280, 100);
    }else{
        (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(-20, -20, ABottomRight)->setSize(280, 50);
    }
}

void WeaponsScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        front_shield_display->setValue(string(my_spaceship->getShieldPercentage(0)) + "%");
        rear_shield_display->setValue(string(my_spaceship->getShieldPercentage(1)) + "%");
        targets.set(my_spaceship->getTarget());

        missile_aim->setVisible(tube_controls->getManualAim());
    }
    GuiOverlay::onDraw(window);
}

void WeaponsScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "WEAPONS" && my_spaceship)
    {
        if (key.hotkey == "NEXT_ENEMY_TARGET")
        {
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (current_found && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && my_spaceship->isEnemy(obj) && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    continue;
                }
                if (my_spaceship->isEnemy(obj) && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
        }
        if (key.hotkey == "NEXT_TARGET")
        {
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (obj == my_spaceship)
                    continue;
                if (current_found && sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get() || obj == my_spaceship)
                    continue;
                if (sf::length(obj->getPosition() - my_spaceship->getPosition()) < 5000 && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
        }
        if (key.hotkey == "AIM_MISSILE_LEFT")
        {
            missile_aim->setValue(missile_aim->getValue() - 5.0f);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
        if (key.hotkey == "AIM_MISSILE_RIGHT")
        {
            missile_aim->setValue(missile_aim->getValue() + 5.0f);
            tube_controls->setMissileTargetAngle(missile_aim->getValue());
        }
    }
}
