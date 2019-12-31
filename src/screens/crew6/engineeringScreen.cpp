#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "engineeringScreen.h"

#include "screenComponents/shipInternalView.h"
#include "screenComponents/selfDestructButton.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_progressslider.h"
#include "gui/gui2_arrow.h"
#include "gui/gui2_image.h"
#include "gui/gui2_panel.h"

EngineeringScreen::EngineeringScreen(GuiContainer* owner, ECrewPosition crew_position)
: GuiOverlay(owner, "ENGINEERING_SCREEN", colorConfig.background), selected_system(SYS_None)
{
    // Render the background decorations.
    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", sf::Color::White);
    background_crosses->setTextureTiled("gui/BackgroundCrosses");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    hull_display = new GuiKeyValueDisplay(this, "HULL_DISPLAY", 0.45, "Hull", "");
    hull_display->setIcon("gui/icons/hull")->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    front_shield_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Front", "");
    front_shield_display->setIcon("gui/icons/shields-fore")->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    rear_shield_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Rear", "");
    rear_shield_display->setIcon("gui/icons/shields-aft")->setTextSize(20)->setPosition(20, 220, ATopLeft)->setSize(240, 40);
    coolant_display = new GuiKeyValueDisplay(this, "COOLANT_DISPLAY", 0.45, "Coolant", "");
    coolant_display->setIcon("gui/icons/coolant")->setTextSize(20)->setPosition(20, 260, ATopLeft)->setSize(240, 40);

    (new GuiSelfDestructButton(this, "SELF_DESTRUCT"))->setPosition(20, 300, ATopLeft)->setSize(240, 100);

    GuiElement* system_config_container = new GuiElement(this, "");
    system_config_container->setPosition(0, -20, ABottomCenter)->setSize(750 + 300, GuiElement::GuiSizeMax);
    GuiAutoLayout* system_row_layouts = new GuiAutoLayout(system_config_container, "SYSTEM_ROWS", GuiAutoLayout::LayoutVerticalBottomToTop);
    system_row_layouts->setPosition(0, 0, ABottomLeft);
    system_row_layouts->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    for(int n=0; n<SYS_COUNT; n++)
    {
        string id = "SYSTEM_ROW_" + getSystemName(ESystem(n));
        SystemRow info;
        info.layout = new GuiAutoLayout(system_row_layouts, id, GuiAutoLayout::LayoutHorizontalLeftToRight);
        info.layout->setSize(GuiElement::GuiSizeMax, 50);

        info.button = new GuiToggleButton(info.layout, id + "_SELECT", getSystemName(ESystem(n)), [this, n](bool value){
            selectSystem(ESystem(n));
        });
        info.button->setSize(300, GuiElement::GuiSizeMax);
        info.damage_bar = new GuiProgressbar(info.layout, id + "_DAMAGE", 0.0, 1.0, 0.0);
        info.damage_bar->setSize(150, GuiElement::GuiSizeMax);
        info.damage_label = new GuiLabel(info.damage_bar, id + "_DAMAGE_LABEL", "...", 20);
        info.damage_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        info.heat_bar = new GuiProgressbar(info.layout, id + "_HEAT", 0.0, 1.0, 0.0);
        info.heat_bar->setSize(100, GuiElement::GuiSizeMax);
        info.heat_arrow = new GuiArrow(info.heat_bar, id + "_HEAT_ARROW", 0);
        info.heat_arrow->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        info.heat_icon = new GuiImage(info.heat_bar, "", "gui/icons/status_overheat");
        info.heat_icon->setColor(colorConfig.overlay_overheating)->setPosition(0, 0, ACenter)->setSize(GuiElement::GuiSizeMatchHeight, GuiElement::GuiSizeMax);
        info.power_bar = new GuiProgressSlider(info.layout, id + "_POWER", 0.0, 3.0, 0.0, [this,n](float value){
            if (my_spaceship)
                my_spaceship->commandSetSystemPowerRequest(ESystem(n), value);
        });
        info.power_bar->setColor(sf::Color(192, 192, 32, 128))->setSize(100, GuiElement::GuiSizeMax);
        info.coolant_bar = new GuiProgressSlider(info.layout, id + "_COOLANT", 0.0, 10.0, 0.0, [this,n](float value){
            if (my_spaceship)
                my_spaceship->commandSetSystemCoolantRequest(ESystem(n), value);
        });
        info.coolant_bar->setColor(sf::Color(32, 128, 128, 128))->setSize(100, GuiElement::GuiSizeMax);
        if (!gameGlobalInfo->use_system_damage){
            info.damage_bar->hide();
            info.heat_bar->setSize(150, GuiElement::GuiSizeMax);
            info.power_bar->setSize(150, GuiElement::GuiSizeMax);
            info.coolant_bar->setSize(150, GuiElement::GuiSizeMax);
        }

        info.layout->moveToBack();
        system_rows.push_back(info);
    }

    GuiAutoLayout* icon_layout = new GuiAutoLayout(system_row_layouts, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    icon_layout->setSize(GuiElement::GuiSizeMax, 48);
    (new GuiElement(icon_layout, "FILLER"))->setSize(300, GuiElement::GuiSizeMax);
    if (gameGlobalInfo->use_system_damage){
        (new GuiImage(icon_layout, "SYSTEM_HEALTH_ICON", "gui/icons/system_health"))->setSize(150, GuiElement::GuiSizeMax);
        (new GuiImage(icon_layout, "HEAT_ICON", "gui/icons/status_overheat"))->setSize(100, GuiElement::GuiSizeMax);
        (new GuiImage(icon_layout, "POWER_ICON", "gui/icons/energy"))->setSize(100, GuiElement::GuiSizeMax);
        (new GuiImage(icon_layout, "COOLANT_ICON", "gui/icons/coolant"))->setSize(100, GuiElement::GuiSizeMax);
    } else {
        (new GuiImage(icon_layout, "HEAT_ICON", "gui/icons/status_overheat"))->setSize(150, GuiElement::GuiSizeMax);
        (new GuiImage(icon_layout, "POWER_ICON", "gui/icons/energy"))->setSize(150, GuiElement::GuiSizeMax);
        (new GuiImage(icon_layout, "COOLANT_ICON", "gui/icons/coolant"))->setSize(150, GuiElement::GuiSizeMax);
    }

    system_rows[SYS_Reactor].button->setIcon("gui/icons/system_reactor");
    system_rows[SYS_BeamWeapons].button->setIcon("gui/icons/system_beam");
    system_rows[SYS_MissileSystem].button->setIcon("gui/icons/system_missile");
    system_rows[SYS_Maneuver].button->setIcon("gui/icons/system_maneuver");
    system_rows[SYS_Impulse].button->setIcon("gui/icons/system_impulse");
    system_rows[SYS_Warp].button->setIcon("gui/icons/system_warpdrive");
    system_rows[SYS_JumpDrive].button->setIcon("gui/icons/system_jumpdrive");
    system_rows[SYS_FrontShield].button->setIcon("gui/icons/shields-fore");
    system_rows[SYS_RearShield].button->setIcon("gui/icons/shields-aft");

    system_effects_container = new GuiAutoLayout(system_config_container, "", GuiAutoLayout::LayoutVerticalBottomToTop);
    system_effects_container->setPosition(0, -400, ABottomRight)->setSize(270, 400);
    GuiPanel* box = new GuiPanel(system_config_container, "POWER_COOLANT_BOX");
    box->setPosition(0, 0, ABottomRight)->setSize(270, 400);
    power_label = new GuiLabel(box, "POWER_LABEL", "Power", 30);
    power_label->setVertical()->setAlignment(ACenterLeft)->setPosition(20, 20, ATopLeft)->setSize(30, 360);
    coolant_label = new GuiLabel(box, "COOLANT_LABEL", "Coolant", 30);
    coolant_label->setVertical()->setAlignment(ACenterLeft)->setPosition(110, 20, ATopLeft)->setSize(30, 360);

    power_slider = new GuiSlider(box, "POWER_SLIDER", 3.0, 0.0, 1.0, [this](float value) {
        if (my_spaceship && selected_system != SYS_None)
            my_spaceship->commandSetSystemPowerRequest(selected_system, value);
    });
    power_slider->setPosition(50, 20, ATopLeft)->setSize(60, 360);
    for(float snap_point = 0.0; snap_point <= 3.0; snap_point += 0.5)
        power_slider->addSnapValue(snap_point, snap_point == 1.0 ? 0.1 : 0.01);
    power_slider->disable();
    coolant_slider = new GuiSlider(box, "COOLANT_SLIDER", 10.0, 0.0, 0.0, [this](float value) {
        if (my_spaceship && selected_system != SYS_None)
            my_spaceship->commandSetSystemCoolantRequest(selected_system, value);
    });
    coolant_slider->setPosition(140, 20, ATopLeft)->setSize(60, 360);
    for(float snap_point = 0.0; snap_point <= 10.0; snap_point += 2.5)
        coolant_slider->addSnapValue(snap_point, 0.1);
    coolant_slider->disable();

    (new GuiShipInternalView(system_row_layouts, "SHIP_INTERNAL_VIEW", 48.0f))->setShip(my_spaceship)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiCustomShipFunctions(this, crew_position, ""))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);

    previous_energy_level = 0.0;
    average_energy_delta = 0.0;
    previous_energy_measurement = 0.0;
}

void EngineeringScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        //Update the energy usage.
        if (previous_energy_measurement == 0.0)
        {
            previous_energy_level = my_spaceship->energy_level;
            previous_energy_measurement = engine->getElapsedTime();
        }else{
            if (previous_energy_measurement != engine->getElapsedTime())
            {
                float delta_t = engine->getElapsedTime() - previous_energy_measurement;
                float delta_e = my_spaceship->energy_level - previous_energy_level;
                float delta_e_per_second = delta_e / delta_t;
                average_energy_delta = average_energy_delta * 0.99 + delta_e_per_second * 0.01;

                previous_energy_level = my_spaceship->energy_level;
                previous_energy_measurement = engine->getElapsedTime();
            }
        }

        energy_display->setValue(string(int(my_spaceship->energy_level)) + " (" + string(int(average_energy_delta * 60.0f)) + "/m)");
        if (my_spaceship->energy_level < 100)
            energy_display->setColor(sf::Color::Red);
        else
            energy_display->setColor(sf::Color::White);
        hull_display->setValue(string(int(100 * my_spaceship->hull_strength / my_spaceship->hull_max)) + "%");
        if (my_spaceship->hull_strength < my_spaceship->hull_max / 4.0f)
            hull_display->setColor(sf::Color::Red);
        else
            hull_display->setColor(sf::Color::White);
        front_shield_display->setValue(string(my_spaceship->getShieldPercentage(0)) + "%");
        rear_shield_display->setValue(string(my_spaceship->getShieldPercentage(1)) + "%");
        coolant_display->setValue(string(int(my_spaceship->max_coolant * 10)) + "%");

        for(int n=0; n<SYS_COUNT; n++)
        {
            SystemRow info = system_rows[n];
            info.layout->setVisible(my_spaceship->hasSystem(ESystem(n)));

            float health = my_spaceship->systems[n].health;
            if (health < 0.0)
                info.damage_bar->setValue(-health)->setColor(sf::Color(128, 32, 32, 192));
            else
                info.damage_bar->setValue(health)->setColor(sf::Color(64, 128 * health, 64 * health, 192));
            info.damage_label->setText(string(int(health * 100)) + "%");

            float heat = my_spaceship->systems[n].heat_level;
            info.heat_bar->setValue(heat)->setColor(sf::Color(128, 32 + 96 * (1.0 - heat), 32, 192));
            float heating_diff = my_spaceship->systems[n].getHeatingDelta();
            if (heating_diff > 0)
                info.heat_arrow->setAngle(90);
            else
                info.heat_arrow->setAngle(-90);
            info.heat_arrow->setVisible(heat > 0);
            info.heat_arrow->setColor(sf::Color(255, 255, 255, std::min(255, int(255 * fabs(heating_diff)))));
            if (heat > 0.9 && fmod(engine->getElapsedTime(), 0.5) < 0.25)
                info.heat_icon->show();
            else
                info.heat_icon->hide();

            info.power_bar->setValue(my_spaceship->systems[n].power_level);
            info.coolant_bar->setValue(my_spaceship->systems[n].coolant_level);
        }

        if (selected_system != SYS_None)
        {
            ShipSystem& system = my_spaceship->systems[selected_system];
            power_label->setText("Power: " + string(int(system.power_level * 100)) + "%/" + string(int(system.power_request * 100)) + "%");
            power_slider->setValue(system.power_request);
            coolant_label->setText("Coolant: " + string(int(system.coolant_level / PlayerSpaceship::max_coolant_per_system * 100)) + "%/" + string(int(std::min(system.coolant_request, my_spaceship->max_coolant) / PlayerSpaceship::max_coolant_per_system * 100)) + "%");
            coolant_slider->setEnable(!my_spaceship->auto_coolant_enabled);
            coolant_slider->setValue(std::min(system.coolant_request, my_spaceship->max_coolant));

            system_effects_index = 0;
            float effectiveness = my_spaceship->getSystemEffectiveness(selected_system);
            switch(selected_system)
            {
            case SYS_Reactor:
                if (effectiveness > 1.0f)
                    effectiveness = (1.0f + effectiveness) / 2.0f;
                addSystemEffect("Energy production", string(effectiveness * -PlayerSpaceship::system_power_user_factor[SYS_Reactor] * 60.0, 1) + "/m");
                break;
            case SYS_BeamWeapons:
                addSystemEffect("Firing rate", string(int(effectiveness * 100)) + "%");
                // If the ship has a turret, also note that the rotation rate
                // is affected.
                for(int n = 0; n < max_beam_weapons; n++)
                {
                    if (my_spaceship->beam_weapons[n].getTurretArc() > 0)
                    {
                        addSystemEffect("Turret rotation rate", string(int(effectiveness * 100)) + "%");
                        break;
                    }
                }
                break;
            case SYS_MissileSystem:
                addSystemEffect("Reload rate", string(int(effectiveness * 100)) + "%");
                break;
            case SYS_Maneuver:
                addSystemEffect("Turning speed", string(int(effectiveness * 100)) + "%");
                if (my_spaceship->combat_maneuver_boost_speed > 0.0 || my_spaceship->combat_maneuver_strafe_speed)
                    addSystemEffect("Combat recharge rate", string(int(((my_spaceship->getSystemEffectiveness(SYS_Maneuver) + my_spaceship->getSystemEffectiveness(SYS_Impulse)) / 2.0) * 100)) + "%");
                break;
            case SYS_Impulse:
                addSystemEffect("Impulse speed", string(int(effectiveness * 100)) + "%");
                if (my_spaceship->combat_maneuver_boost_speed > 0.0 || my_spaceship->combat_maneuver_strafe_speed)
                    addSystemEffect("Combat recharge rate", string(int(((my_spaceship->getSystemEffectiveness(SYS_Maneuver) + my_spaceship->getSystemEffectiveness(SYS_Impulse)) / 2.0) * 100)) + "%");
                break;
            case SYS_Warp:
                addSystemEffect("Warp drive speed", string(int(effectiveness * 100)) + "%");
                break;
            case SYS_JumpDrive:
                addSystemEffect("Jump drive recharge rate", string(int(my_spaceship->getJumpDriveRechargeRate() * 100)) + "%");
                addSystemEffect("Jump drive jump speed", string(int(effectiveness * 100)) + "%");
                break;
            case SYS_FrontShield:
                if (gameGlobalInfo->use_beam_shield_frequencies)
                    addSystemEffect("Calibration speed", string(int((my_spaceship->getSystemEffectiveness(SYS_FrontShield) + my_spaceship->getSystemEffectiveness(SYS_RearShield)) / 2.0 * 100)) + "%");
                addSystemEffect("Charge rate", string(int(effectiveness * 100)) + "%");
                {
                    DamageInfo di;
                    di.type = DT_Kinetic;
                    float damage_negate = 1.0f - my_spaceship->getShieldDamageFactor(di, 0);
                    if (damage_negate < 0.0)
                        addSystemEffect("Extra damage", string(int(-damage_negate * 100)) + "%");
                    else
                        addSystemEffect("Damage negate", string(int(damage_negate * 100)) + "%");
                }
                break;
            case SYS_RearShield:
                if (gameGlobalInfo->use_beam_shield_frequencies)
                    addSystemEffect("Calibration speed", string(int((my_spaceship->getSystemEffectiveness(SYS_FrontShield) + my_spaceship->getSystemEffectiveness(SYS_RearShield)) / 2.0 * 100)) + "%");
                addSystemEffect("Charge rate", string(int(effectiveness * 100)) + "%");
                {
                    DamageInfo di;
                    di.type = DT_Kinetic;
                    float damage_negate = 1.0f - 
my_spaceship->getShieldDamageFactor(di, my_spaceship->shield_count - 1);
                    if (damage_negate < 0.0)
                        addSystemEffect("Extra damage", string(int(-damage_negate * 100)) + "%");
                    else
                        addSystemEffect("Damage negate", string(int(damage_negate * 100)) + "%");
                }
                break;
            default:
                break;
            }
            for(unsigned int idx=system_effects_index; idx<system_effects.size(); idx++)
                system_effects[idx]->hide();
        }
    }
    GuiOverlay::onDraw(window);
}

void EngineeringScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "ENGINEERING" && my_spaceship)
    {
        if (key.hotkey == "SELECT_REACTOR") selectSystem(SYS_Reactor);
        if (key.hotkey == "SELECT_BEAM_WEAPONS") selectSystem(SYS_BeamWeapons);
        if (key.hotkey == "SELECT_MISSILE_SYSTEM") selectSystem(SYS_MissileSystem);
        if (key.hotkey == "SELECT_MANEUVER") selectSystem(SYS_Maneuver);
        if (key.hotkey == "SELECT_IMPULSE") selectSystem(SYS_Impulse);
        if (key.hotkey == "SELECT_WARP") selectSystem(SYS_Warp);
        if (key.hotkey == "SELECT_JUMP_DRIVE") selectSystem(SYS_JumpDrive);
        if (key.hotkey == "SELECT_FRONT_SHIELDS") selectSystem(SYS_FrontShield);
        if (key.hotkey == "SELECT_REAR_SHIELDS") selectSystem(SYS_RearShield);
        
        if (selected_system != SYS_None)
        {
            if (key.hotkey == "INCREASE_POWER")
            {
                power_slider->setValue(my_spaceship->systems[selected_system].power_request + 0.1f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (key.hotkey == "DECREASE_POWER")
            {
                power_slider->setValue(my_spaceship->systems[selected_system].power_request - 0.1f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (key.hotkey == "INCREASE_COOLANT")
            {
                coolant_slider->setValue(my_spaceship->systems[selected_system].coolant_request + 0.5f);
                my_spaceship->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
            }
            if (key.hotkey == "DECREASE_COOLANT")
            {
                coolant_slider->setValue(my_spaceship->systems[selected_system].coolant_request - 0.5f);
                my_spaceship->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
            }
        }
    }
}

void EngineeringScreen::selectSystem(ESystem system)
{
    if (my_spaceship && !my_spaceship->hasSystem(system))
        return;
    
    for(int idx=0; idx<SYS_COUNT; idx++)
    {
        system_rows[idx].button->setValue(idx == system);
    }
    selected_system = system;
    power_slider->enable();
    if (my_spaceship)
    {
        power_slider->setValue(my_spaceship->systems[system].power_request);
        coolant_slider->setValue(my_spaceship->systems[system].coolant_request);
    }
}

void EngineeringScreen::addSystemEffect(string key, string value)
{
    if (system_effects_index == system_effects.size())
    {
        GuiKeyValueDisplay* item = new GuiKeyValueDisplay(system_effects_container, "", 0.75, key, value);
        item->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 40);
        system_effects.push_back(item);
    }else{
        system_effects[system_effects_index]->setKey(key);
        system_effects[system_effects_index]->setValue(value);
        system_effects[system_effects_index]->show();
    }
    system_effects_index++;
}
