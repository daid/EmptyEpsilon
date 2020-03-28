#include "powerManagement.h"

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_keyvaluedisplay.h"

PowerManagementScreen::PowerManagementScreen(GuiContainer* owner)
: GuiOverlay(owner, "POWER_MANAGEMENT_SCREEN", colorConfig.background)
{
    selected_system = SYS_None;

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 20, ATopLeft)->setSize(285, 40);
    coolant_display = new GuiKeyValueDisplay(this, "COOLANT_DISPLAY", 0.45, "Coolant", "");
    coolant_display->setIcon("gui/icons/coolant")->setTextSize(20)->setPosition(315, 20, ATopLeft)->setSize(280, 40);
    GuiAutoLayout* layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    layout->setPosition(20, 60, ATopLeft)->setSize(GuiElement::GuiSizeMax, 400);
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (n == 4)
        {
            //Start the 2nd row after 4 elements.
            layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
            layout->setPosition(20, 450, ATopLeft)->setSize(GuiElement::GuiSizeMax, 400);
        }

        GuiPanel* box = new GuiPanel(layout, "");
        systems[n].box = box;
        box->setSize(290, 400);

        (new GuiLabel(box, "", getLocaleSystemName(ESystem(n)), 30))->addBackground()->setAlignment(ACenter)->setPosition(0, 0, ATopLeft)->setSize(290, 50);
        (new GuiLabel(box, "", "Power", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(20, 50, ATopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", "Coolant", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(100, 50, ATopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", "Heat", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(180, 50, ATopLeft)->setSize(30, 340);

        systems[n].power_bar = new GuiProgressbar(box, "", 0.0, 3.0, 1.0);
        systems[n].power_bar->setDrawBackground(false)->setPosition(52.5, 60, ATopLeft)->setSize(50, 320);

        systems[n].power_slider = new GuiSlider(box, "", 3.0, 0.0, 1.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemPowerRequest(ESystem(n), value);
        });
        systems[n].power_slider->addSnapValue(1.0, 0.1)->setPosition(50, 50, ATopLeft)->setSize(55, 340);

        systems[n].coolant_bar = new GuiProgressbar(box, "", 0.0, 10.0, 0.0);
        systems[n].coolant_bar->setDrawBackground(false)->setPosition(132.5, 60, ATopLeft)->setSize(50, 320);

        systems[n].coolant_slider = new GuiSlider(box, "", 10.0, 0.0, 0.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemCoolantRequest(ESystem(n), value);
        });
        systems[n].coolant_slider->setPosition(130, 50, ATopLeft)->setSize(55, 340);

        systems[n].heat_bar = new GuiProgressbar(box, "", 0.0, 1.0, 0.0);
        systems[n].heat_bar->setPosition(210, 60, ATopLeft)->setSize(50, 320);
    }

    (new GuiCustomShipFunctions(this, powerManagement, ""))->setPosition(-20, 120, ATopRight)->setSize(250, GuiElement::GuiSizeMax);

    previous_energy_level = 0.0;
    average_energy_delta = 0.0;
    previous_energy_measurement = 0.0;

    // TODO: Hotkey help overlay
}

void PowerManagementScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
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
        coolant_display->setValue(string(int(my_spaceship->max_coolant * 10)) + "%");

        for(int n=0; n<SYS_COUNT; n++)
        {
            systems[n].box->setVisible(my_spaceship->hasSystem(ESystem(n)));
            systems[n].power_slider->setValue(my_spaceship->systems[n].power_request);
            systems[n].coolant_slider->setValue(std::min(my_spaceship->systems[n].coolant_request, my_spaceship->max_coolant));
            systems[n].coolant_slider->setEnable(!my_spaceship->auto_coolant_enabled);

            float heat = my_spaceship->systems[n].heat_level;
            float power = my_spaceship->systems[n].power_level;
            float coolant = my_spaceship->systems[n].coolant_level;
            systems[n].heat_bar->setValue(heat)->setColor(sf::Color(128, 128 * (1.0 - heat), 0));
            systems[n].power_bar->setValue(power)->setColor(sf::Color(255, 255, 0));
            systems[n].coolant_bar->setValue(coolant)->setColor(sf::Color(0,128,255));
        }
    }
}

void PowerManagementScreen::onHotkey(const HotkeyResult& key)
{
    if (key.category == "ENGINEERING" && my_spaceship)
    {
        if (key.hotkey == "SELECT_REACTOR") selected_system = SYS_Reactor;
        if (key.hotkey == "SELECT_BEAM_WEAPONS") selected_system = SYS_BeamWeapons;
        if (key.hotkey == "SELECT_MISSILE_SYSTEM") selected_system = SYS_MissileSystem;
        if (key.hotkey == "SELECT_MANEUVER") selected_system = SYS_Maneuver;
        if (key.hotkey == "SELECT_IMPULSE") selected_system = SYS_Impulse;
        if (key.hotkey == "SELECT_WARP") selected_system = SYS_Warp;
        if (key.hotkey == "SELECT_JUMP_DRIVE") selected_system = SYS_JumpDrive;
        if (key.hotkey == "SELECT_FRONT_SHIELDS") selected_system = SYS_FrontShield;
        if (key.hotkey == "SELECT_REAR_SHIELDS") selected_system = SYS_RearShield;

        // Don't act if the selected system doesn't exist.
        if (!my_spaceship->hasSystem(selected_system))
            return;

        // If we selected a system, check for the power/coolant modifier.
        if (selected_system != SYS_None)
        {
            GuiSlider* power_slider = systems[selected_system].power_slider;

            if (key.hotkey == "INCREASE_POWER")
            {
                power_slider->setValue(my_spaceship->systems[selected_system].power_request + 0.1f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
                return;
            } else if (key.hotkey == "DECREASE_POWER") {
                power_slider->setValue(my_spaceship->systems[selected_system].power_request - 0.1f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
                return;
            }

            GuiSlider* coolant_slider = systems[selected_system].coolant_slider;

            if (key.hotkey == "INCREASE_COOLANT")
            {
                coolant_slider->setValue(my_spaceship->systems[selected_system].coolant_request + 0.5f);
                my_spaceship->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
                return;
            } else if (key.hotkey == "DECREASE_COOLANT") {
                coolant_slider->setValue(my_spaceship->systems[selected_system].coolant_request - 0.5f);
                my_spaceship->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
                return;
            }
        }
    }
}

bool PowerManagementScreen::onJoystickAxis(const AxisAction& axisAction){
    if(my_spaceship){
        if (axisAction.category == "ENGINEERING"){
            for(int n=0; n<SYS_COUNT; n++)
            {
                ESystem system = ESystem(n);
                if (axisAction.action == std::string("POWER_") + getSystemName(system)){
                    systems[n].power_slider->setValue((axisAction.value + 1) * 3.0 / 2.0);
                    my_spaceship->commandSetSystemPowerRequest(system, systems[n].power_slider->getValue());
                    return true;
                } 
                if (axisAction.action == std::string("COOLANT_") + getSystemName(system)){
                    systems[n].coolant_slider->setValue((axisAction.value + 1) * 10.0 / 2.0);
                    my_spaceship->commandSetSystemCoolantRequest(system, systems[n].coolant_slider->getValue());
                    return true;
                }
            }
        }
    }
    return false;
}
