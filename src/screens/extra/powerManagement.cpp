#include "powerManagement.h"
#include "missileWeaponData.h"

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

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(285, 40);
    coolant_display = new GuiKeyValueDisplay(this, "COOLANT_DISPLAY", 0.45, tr("Coolant"), "");
    coolant_display->setIcon("gui/icons/coolant")->setTextSize(20)->setPosition(315, 20, sp::Alignment::TopLeft)->setSize(280, 40);
    GuiElement* layout = new GuiElement(this, "");
    layout->setPosition(20, 60, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 400)->setAttribute("layout", "horizontal");
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (n == 4)
        {
            //Start the 2nd row after 4 elements.
            layout = new GuiElement(this, "");
            layout->setPosition(20, 450, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 400)->setAttribute("layout", "horizontal");;
        }

        GuiPanel* box = new GuiPanel(layout, "");
        systems[n].box = box;
        box->setSize(290, 400);

        (new GuiLabel(box, "", getLocaleSystemName(ESystem(n)), 30))->addBackground()->setAlignment(sp::Alignment::Center)->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(290, 50);
        (new GuiLabel(box, "", tr("button", "Power"), 30))->setVertical()->setAlignment(sp::Alignment::CenterLeft)->setPosition(20, 50, sp::Alignment::TopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", tr("button", "Coolant"), 30))->setVertical()->setAlignment(sp::Alignment::CenterLeft)->setPosition(100, 50, sp::Alignment::TopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", tr("button", "Heat"), 30))->setVertical()->setAlignment(sp::Alignment::CenterLeft)->setPosition(180, 50, sp::Alignment::TopLeft)->setSize(30, 340);

        systems[n].power_bar = new GuiProgressbar(box, "", 0.0, 3.0, 1.0);
        systems[n].power_bar->setDrawBackground(false)->setPosition(52.5, 60, sp::Alignment::TopLeft)->setSize(50, 320);

        systems[n].power_slider = new GuiSlider(box, "", 3.0, 0.0, 1.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemPowerRequest(ESystem(n), value);
        });
        systems[n].power_slider->addSnapValue(1.0, 0.1)->setPosition(50, 50, sp::Alignment::TopLeft)->setSize(55, 340);

        systems[n].coolant_bar = new GuiProgressbar(box, "", 0.0, 10.0, 0.0);
        systems[n].coolant_bar->setDrawBackground(false)->setPosition(132.5, 60, sp::Alignment::TopLeft)->setSize(50, 320);

        systems[n].coolant_slider = new GuiSlider(box, "", 10.0, 0.0, 0.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemCoolantRequest(ESystem(n), value);
        });
        systems[n].coolant_slider->setPosition(130, 50, sp::Alignment::TopLeft)->setSize(55, 340);

        systems[n].heat_bar = new GuiProgressbar(box, "", 0.0, 1.0, 0.0);
        systems[n].heat_bar->setPosition(210, 60, sp::Alignment::TopLeft)->setSize(50, 320);
    }

    (new GuiCustomShipFunctions(this, powerManagement, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);

    previous_energy_level = 0.0;
    average_energy_delta = 0.0;
    previous_energy_measurement = 0.0;

    // TODO: Hotkey help overlay
}

void PowerManagementScreen::onDraw(sp::RenderTarget& renderer)
{
    GuiOverlay::onDraw(renderer);
    if (my_spaceship)
    {
        //Update the energy usage.
        if (previous_energy_measurement == 0.0f)
        {
            previous_energy_level = my_spaceship->energy_level;
            previous_energy_measurement = engine->getElapsedTime();
        }else{
            if (previous_energy_measurement != engine->getElapsedTime())
            {
                float delta_t = engine->getElapsedTime() - previous_energy_measurement;
                float delta_e = my_spaceship->energy_level - previous_energy_level;
                float delta_e_per_second = delta_e / delta_t;
                average_energy_delta = average_energy_delta * 0.99f + delta_e_per_second * 0.01f;

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
            systems[n].heat_bar->setValue(heat)->setColor(glm::u8vec4(128, 128 * (1.0f - heat), 0, 255));
            systems[n].power_bar->setValue(power)->setColor(glm::u8vec4(255, 255, 0, 255));
            systems[n].coolant_bar->setValue(coolant)->setColor(glm::u8vec4(0, 128, 255, 255));
        }
    }
}

void PowerManagementScreen::onUpdate()
{
    if (my_spaceship)
    {
        if (keys.engineering_select_reactor.getDown()) selected_system = SYS_Reactor;
        if (keys.engineering_select_beam_weapons.getDown()) selected_system = SYS_BeamWeapons;
        if (keys.engineering_select_missile_system.getDown()) selected_system = SYS_MissileSystem;
        if (keys.engineering_select_maneuvering_system.getDown()) selected_system = SYS_Maneuver;
        if (keys.engineering_select_impulse_system.getDown()) selected_system = SYS_Impulse;
        if (keys.engineering_select_warp_system.getDown()) selected_system = SYS_Warp;
        if (keys.engineering_select_jump_drive_system.getDown()) selected_system = SYS_JumpDrive;
        if (keys.engineering_select_front_shield_system.getDown()) selected_system = SYS_FrontShield;
        if (keys.engineering_select_rear_shield_system.getDown()) selected_system = SYS_RearShield;

        // Don't act if the selected system doesn't exist.
        if (!my_spaceship->hasSystem(selected_system))
            return;

        // If we selected a system, check for the power/coolant modifier.
        if (selected_system != SYS_None)
        {
            GuiSlider* power_slider = systems[selected_system].power_slider;

            // Note the code duplication with crew6/engineeringScreen
            if (keys.engineering_set_power_000.getDown())
            {
                power_slider->setValue(0.0f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_030.getDown())
            {
                power_slider->setValue(0.3f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_050.getDown())
            {
                power_slider->setValue(0.5f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_100.getDown())
            {
                power_slider->setValue(1.0f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_150.getDown())
            {
                power_slider->setValue(1.5f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_200.getDown())
            {
                power_slider->setValue(2.0f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_250.getDown())
            {
                power_slider->setValue(2.5f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_300.getDown())
            {
                power_slider->setValue(3.0f);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }

            auto power_adjust = (keys.engineering_increase_power.getValue() - keys.engineering_decrease_power.getValue()) * 0.1f;
            if (power_adjust != 0.0f)
            {
                power_slider->setValue(my_spaceship->systems[selected_system].power_request + power_adjust);
                my_spaceship->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }

            GuiSlider* coolant_slider = systems[selected_system].coolant_slider;
            auto coolant_adjust = (keys.engineering_increase_coolant.getValue() - keys.engineering_decrease_coolant.getValue()) * 0.5f;
            if (coolant_adjust != 0.0f)
            {
                coolant_slider->setValue(my_spaceship->systems[selected_system].coolant_request + coolant_adjust);
                my_spaceship->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
            }
        }
    }
}
