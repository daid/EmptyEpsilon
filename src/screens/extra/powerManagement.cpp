#include "powerManagement.h"
#include "i18n.h"
#include "missileWeaponData.h"
#include "components/reactor.h"
#include "components/coolant.h"

#include "playerInfo.h"
#include "screenComponents/customShipFunctions.h"
#include "engine.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_arrow.h"
#include "gui/gui2_image.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_keyvaluedisplay.h"

PowerManagementScreen::PowerManagementScreen(GuiContainer* owner)
: GuiOverlay(owner, "POWER_MANAGEMENT_SCREEN", colorConfig.background), active_system_count(0), panel_size({290.0f, 380.0f}), previous_energy_level(0.0f), average_energy_delta(0.0f), previous_energy_measurement(0.0f), selected_system(ShipSystem::Type::None)
{
    // Initialize layout containers
    GuiElement* layout = new GuiElement(this, "PWR_LAYOUT");
    layout->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    layout->setAttribute("layout", "vertical");
    layout->setAttribute("padding", string(layout_margin));

    // Status bar across top for power and coolant gauges.
    status_bar = new GuiElement(layout, "PWR_STATUS_BAR");
    status_bar->setSize(GuiElement::GuiSizeMax, status_bar_height);
    status_bar->setAttribute("layout", "horizontal");
    // Add padding to preserve space at top right for the 250px-wide crew screen
    // selector and main screen controls.
    status_bar->setAttribute("padding", "0, 270, 0, 0");

    // Build the status bar, which contains energy and coolant gauges.
    energy_capacity_gauge = new GuiProgressbar(status_bar, "PWR_ENERGY_CAPACITY_GAUGE", 0.0f, 1000.0f, 1000.0f);
    energy_capacity_gauge
        ->setDrawBackground(false)
        ->setColor(energy_color_background)
        ->setPosition(0.0f, 0.0f, sp::Alignment::CenterLeft)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("margin", "0, 13");

    energy_display = new GuiKeyValueDisplay(energy_capacity_gauge, "PWR_ENERGY_DISPLAY", 0.6f, tr("power management", "Available energy") + "\n" + tr("power management", "Drain/charge rate"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(25.0f)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("margin", "0, -13");
    energy_delta_arrow = new GuiArrow(energy_display, "PWR_ENERGY_DELTA_ARROW", 0.0f);
    energy_delta_arrow->setPosition(0.0f, 0.0f, sp::Alignment::CenterRight)->setSize(40.0f, 40.0f);

    GuiElement* status_bar_kv_spacer = new GuiElement(status_bar, "PWR_STATUS_BAR_KV_SPACER");
    status_bar_kv_spacer->setSize(20.0f, GuiElement::GuiSizeMax);

    coolant_distribution_gauge = new GuiProgressbar(status_bar, "PWR_COOLANT_DISTRIBUTION_GAUGE", 0.0f, 1.0f, 1.0f);
    coolant_distribution_gauge
        ->setDrawBackground(false)
        ->setColor(coolant_color_background)
        ->setPosition(0.0f, 0.0f, sp::Alignment::CenterLeft)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("margin", "0, 13");

    coolant_display = new GuiKeyValueDisplay(coolant_distribution_gauge, "PWR_COOLANT_DISPLAY", 0.7f, tr("power management", "Available coolant"), "");
    coolant_display->setIcon("gui/icons/coolant")->setTextSize(25.0f)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("margin", "0, -13");

    // Build the content container for the columns below status bar.
    GuiElement* content = new GuiElement(layout, "PWR_CONTENT");
    content->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    content->setAttribute("layout", "horizontal");

    // Left column contains the grid of systems power management panels.
    systems_grid = new GuiElement(content, "PWR_SYSTEMS_GRID");
    systems_grid->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    systems_grid->setAttribute("layout", "vertical");

    // Right column contains the custom functions element.
    custom_functions = new GuiCustomShipFunctions(content, CrewPosition::powerManagement, "PWR_CUSTOM_FUNCTIONS");
    custom_functions->setSize(custom_functions_width, GuiElement::GuiSizeMax);

    // Initialize at least one row for systems panels.
    GuiElement* systems_row = new GuiElement(systems_grid, "PWR_SYSTEMS_ROW_1");
    systems_row->setSize(GuiElement::GuiSizeMax, panel_size.y);
    systems_row->setAttribute("layout", "horizontal");
    systems_rows.emplace_back(systems_row);

    // TODO: Hotkey help overlay
}

bool PowerManagementScreen::populateSystemPanel(int system_index, GuiElement* systems_row)
{
    // Populate a single system's power management panel for the systems grid.
    // Return if there's no my_spaceship.
    if (!my_spaceship) return false;

    // If a container already exists for this system, reparent it to the new row instead of recreating widgets.
    if (auto this_container = systems[system_index].container)
        this_container->setParent(systems_row);
    else
    {
        // Create the container and its child widgets if they don't exist yet.
        systems[system_index].container = new GuiPanel(systems_row, "PWR_SYSTEM_CONTAINER_" + string(system_index));
        systems[system_index].container->setSize(panel_size.x, GuiElement::GuiSizeMax);
        systems[system_index].container->setAttribute("layout", "vertical");
        systems[system_index].container->setAttribute("padding", "20, 20, 10, 20");

        // Build the panel label.
        // Select an icon for systems that support it.
        string icon_file = "";
        switch (system_index)
        {
            case int(ShipSystem::Type::Reactor):
                icon_file = "gui/icons/system_reactor";
                break;
            case int(ShipSystem::Type::BeamWeapons):
                icon_file = "gui/icons/system_beam";
                break;
            case int(ShipSystem::Type::MissileSystem):
                icon_file = "gui/icons/system_missile";
                break;
            case int(ShipSystem::Type::Maneuver):
                icon_file = "gui/icons/system_maneuver";
                break;
            case int(ShipSystem::Type::Impulse):
                icon_file = "gui/icons/system_impulse";
                break;
            case int(ShipSystem::Type::Warp):
                icon_file = "gui/icons/system_warpdrive";
                break;
            case int(ShipSystem::Type::JumpDrive):
                icon_file = "gui/icons/system_jumpdrive";
                break;
            case int(ShipSystem::Type::FrontShield):
                icon_file = "gui/icons/shields-fore";
                break;
            case int(ShipSystem::Type::RearShield):
                icon_file = "gui/icons/shields-aft";
                break;
        }

        // Panel labels use GuiKeyValueDisplay for their icon support.
        systems[system_index].system_label = new GuiKeyValueDisplay(systems[system_index].container, "PWR_SYSTEM_" + string(system_index) + "_NAME_LABEL", 0.15f, "", getLocaleSystemName(ShipSystem::Type(system_index)));
        systems[system_index].system_label->setIcon(icon_file)->setTextSize(20.0f)->setSize(GuiElement::GuiSizeMax, 50.0f);
        systems[system_index].system_label->setAttribute("margin", "0, 0, -12, 0");

        // Build the panel's sliders.
        systems[system_index].system_container_sliders = new GuiElement(systems[system_index].container, "PWR_SYSTEM_" + string(system_index) + "_SLIDERS");
        systems[system_index].system_container_sliders->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        systems[system_index].system_container_sliders->setAttribute("layout", "horizontal");

        // Build the power slider.
        systems[system_index].power_label = new GuiLabel(systems[system_index].system_container_sliders, "PWR_SYSTEM_" + string(system_index) + "_POWER_LABEL", tr("button", "Power"), 30.0f);
        systems[system_index].power_label
            ->setVertical()
            ->setAlignment(sp::Alignment::CenterLeft)
            ->setSize(30.0f, GuiElement::GuiSizeMax)
            ->setAttribute("margin", "0, 10, 0, 0");

        // Build an element to contain the power slider/progressbar combo.
        systems[system_index].power_control = new GuiElement(systems[system_index].system_container_sliders, "PWR_SYSTEM_" + string(system_index) + "_CONTROLS");
        systems[system_index].power_control->setSize(40.0f, GuiElement::GuiSizeMax);

        systems[system_index].power_bar = new GuiProgressbar(systems[system_index].power_control, "PWR_SYSTEM_" + string(system_index) + "_POWER_BAR", 0.0f, 3.0f, 1.0f);
        systems[system_index].power_bar->setDrawBackground(false)->setColor(energy_color_background)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        // Vertical margins fit the bar to the 0-100 marks on the slider, which differ from the top and bottom extents.
        // Horizontal margins needed to fit the bar inside of the default slider background image's borders.
        systems[system_index].power_bar->setAttribute("margin", "3, 20");

        systems[system_index].power_slider = new GuiSlider(systems[system_index].power_control, "PWR_SYSTEM_" + string(system_index) + "_POWER_SLIDER", 3.0f, 0.0f, 1.0f,
            [system_index](float value)
            {
                my_player_info->commandSetSystemPowerRequest(ShipSystem::Type(system_index), value);
            }
        );
        systems[system_index].power_slider->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        // Snap points copied from Engineering.
        for (float snap_point = 0.0f; snap_point <= 3.0f; snap_point += 0.5f)
            systems[system_index].power_slider->addSnapValue(snap_point, snap_point == 1.0f ? 0.1f : 0.01f);

        // Build the coolant slider.
        systems[system_index].coolant_label = new GuiLabel(systems[system_index].system_container_sliders, "PWR_SYSTEM_" + string(system_index) + "_COOLANT_LABEL", tr("button", "Coolant"), 30.0f);
        systems[system_index].coolant_label
            ->setVertical()
            ->setAlignment(sp::Alignment::CenterLeft)
            ->setSize(30.0f, GuiElement::GuiSizeMax)
            ->setAttribute("margin", "0, 10, 0, 0");

        // Build an element to contain the slider/progressbar combos.
        systems[system_index].coolant_control = new GuiElement(systems[system_index].system_container_sliders, "PWR_SYSTEM_" + string(system_index) + "_CONTROLS");
        systems[system_index].coolant_control->setSize(40.0f, GuiElement::GuiSizeMax);

        systems[system_index].coolant_bar = new GuiProgressbar(systems[system_index].coolant_control, "PWR_SYSTEM_" + string(system_index) + "_COOLANT_BAR", 0.0f, 10.0f, 1.0f);
        systems[system_index].coolant_bar->setDrawBackground(false)->setColor(coolant_color_background)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        // Vertical margins fit the bar to the 0-100 marks on the slider, which differ from the top and bottom extents.
        // Horizontal margins needed to fit the bar inside of the default slider background image's borders.
        systems[system_index].coolant_bar->setAttribute("margin", "3, 20");

        systems[system_index].coolant_slider = new GuiSlider(systems[system_index].coolant_control, "PWR_SYSTEM_" + string(system_index) + "_COOLANT_SLIDER", 10.0f, 0.0f, 1.0f,
            [system_index](float value)
            {
                my_player_info->commandSetSystemCoolantRequest(ShipSystem::Type(system_index), value);
            }
        );
        systems[system_index].coolant_slider->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        // Snap points copied from Engineering.
        for (float snap_point = 0.0f; snap_point <= 10.0f; snap_point += 2.5f)
            systems[system_index].coolant_slider->addSnapValue(snap_point, 0.1f);

        // Build the heat bar.
        systems[system_index].heat_label = new GuiLabel(systems[system_index].system_container_sliders, "PWR_SYSTEM_" + string(system_index) + "_HEAT_LABEL", tr("button", "Heat"), 30.0f);
        systems[system_index].heat_label
            ->setVertical()
            ->setAlignment(sp::Alignment::CenterLeft)
            ->setSize(30.0f, GuiElement::GuiSizeMax)
            ->setAttribute("margin", "0, 10, 0, 0");
        systems[system_index].heat_bar = new GuiProgressbar(systems[system_index].system_container_sliders, "PWR_SYSTEM_" + string(system_index) + "_HEAT_BAR", 0.0f, 1.0f, 0.0f);
        systems[system_index].heat_bar->setSize(40.0f, GuiElement::GuiSizeMax);
        // Vertical margins keep the bar aligned with the sliders' Progressbars.
        // If sliders gain an uncapped option, we might be able to do away with
        // this.
        systems[system_index].heat_bar->setAttribute("margin", "0, 20");

        systems[system_index].heat_arrow = new GuiArrow(systems[system_index].heat_bar, "PWR_SYSTEM_" + string(system_index) + "_HEAT_ARROW", 90.0f);
        systems[system_index].heat_arrow->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    }

    // If this system doesn't exist on this ship, it'll be hidden.
    // Return false to communicate this, for instance to skip assigning a row
    // index upon panel population, so subsequent panels behave as expected.
    if (!ShipSystem::get(my_spaceship, ShipSystem::Type(system_index))) return false;

    return true;
}

void PowerManagementScreen::onDraw(sp::RenderTarget& renderer)
{
    GuiOverlay::onDraw(renderer);
    if (!my_spaceship) return;

    auto coolant = my_spaceship.getComponent<Coolant>();
    float unused_coolant = 0.0f;
    // Get view size and calculate content dimensions.
    const glm::vec2 old_size = view_size;
    view_size = getRect().size;
    // "Main content" refers to the area containing the systems grid.
    const float main_content_height = view_size.y - float(layout_margin * 2) - status_bar_height;

    // Show or hide custom functions depending on whether any exist.
    // Reduce the horizontal view size if showoing the custom functions column.
    if (custom_functions->hasEntries())
    {
        custom_functions->show();
        view_size.x -= custom_functions_width;
    }
    else custom_functions->hide();

    // Force a hard limit on status bar width in wide views.
    if (view_size.x > 1360.0f)
    {
        status_bar->layout.fill_width = false;
        status_bar->setSize(panel_size.x * 4.0f, status_bar_height);
    }
    else status_bar->setSize(GuiElement::GuiSizeMax, status_bar_height);

    // Count active systems for row assignments.
    // We don't want systems that aren't added to this ship to be counted
    // toward row assignments.
    const int old_system_count = active_system_count;
    active_system_count = 0;
    for (int n = 0; n < ShipSystem::COUNT; n++)
        active_system_count += ShipSystem::get(my_spaceship, ShipSystem::Type(n)) ? 1 : 0;

    // If the view size or active systems count have changed, update the
    // systems grid.
    if (old_size != view_size || old_system_count != active_system_count)
    {
        // Determine number of panels per row by available width / panel width.
        // Ensure at least one panel per row.
        const int panels_per_row = std::max(1, int((view_size.x - 40.0f) / panel_size.x));

        // Compute how many rows are required.
        const int new_rows = std::max(1, (active_system_count + (panels_per_row - 1)) / panels_per_row);

        // Reduce panel size height to squeeze in more panels, but only if necessary.
        panel_size.y = std::clamp(main_content_height / new_rows, 250.0f, 380.0f);
        for (auto resized_row : systems_rows) resized_row->setSize(GuiElement::GuiSizeMax, panel_size.y);

        // If the systems or window size have changed to require more rows,
        // add rows.
        while (int(systems_rows.size()) < new_rows)
        {
            GuiElement* systems_row = new GuiElement(this->systems_grid, "PWR_SYSTEMS_ROW_" + string(int(systems_rows.size()) + 1));
            systems_row->setSize(GuiElement::GuiSizeMax, panel_size.y);
            systems_row->setAttribute("layout", "horizontal");
            systems_rows.emplace_back(systems_row);
        }

        // If the systems or window size have changed to require fewer rows,
        // destroy unnecessary rows.
        while (!systems_rows.empty() && int(systems_rows.size()) > new_rows)
        {
            systems_rows.back()->destroy();
            systems_rows.pop_back();
        }

        // Place each system into a row while skipping absent systems.
        // If a system is added or removed from a ship during play, the rows
        // should automatically repopulate.
        int row_index = 0;
        for (int n = 0; n < ShipSystem::COUNT; n++)
        {
            if (populateSystemPanel(n, systems_rows[std::clamp(row_index / panels_per_row, 0, int(systems_rows.size()) - 1)]))
                row_index++;
        }
    }

    // Update reactor-related properties of energy and heat.
    if (auto reactor = my_spaceship.getComponent<Reactor>())
    {
        // Update energy usage.
        if (previous_energy_measurement == 0.0f)
        {
            previous_energy_level = reactor->energy;
            previous_energy_measurement = engine->getElapsedTime();
        }
        else if (previous_energy_measurement != engine->getElapsedTime())
        {
            float delta_t = engine->getElapsedTime() - previous_energy_measurement;
            float delta_e = reactor->energy - previous_energy_level;
            float delta_e_per_second = delta_e / delta_t;
            average_energy_delta = average_energy_delta * 0.99f + delta_e_per_second * 0.01f;

            previous_energy_level = reactor->energy;
            previous_energy_measurement = engine->getElapsedTime();
        }

        // Update energy status bar.
        const float energy_delta_per_minute = average_energy_delta * 60.0f;

        energy_display->setValue(
            string(int(reactor->energy)) + "/" + string(int(reactor->max_energy)) + "\n" + tr("{energy_delta}/min.").format(
            {
                {"energy_delta", string(int(energy_delta_per_minute))}
            }
        ));

        energy_capacity_gauge->setRange(0.0f, reactor->max_energy)->setValue(reactor->energy);

        energy_delta_arrow
            ->setAngle(energy_delta_per_minute > 0.0f ? 180.0f : 0.0f)
            ->setColor(glm::u8vec4(255, 255, 255, std::min(255, int(255.0f * fabs(energy_delta_per_minute / 250.0f)))))
            ->setVisible(energy_delta_per_minute != 0.0f);
    }
    else energy_capacity_gauge->hide();

    if (coolant)
    {
        coolant_display->setVisible(coolant);
        coolant_distribution_gauge->setVisible(coolant);
        unused_coolant = coolant->max;
    }

    // Update system properties.
    for (int n = 0; n < ShipSystem::COUNT; n++)
    {
        if (auto sys = ShipSystem::get(my_spaceship, ShipSystem::Type(n)))
        {
            systems[n].container->show();

            // Update the system's power request label, slider, and bar.
            systems[n].power_label->setText(tr("Power: {value}%").format({{"value", static_cast<int>(nearbyint(sys->power_level * 100.0f))}}));
            systems[n].power_slider->setValue(sys->power_request);
            systems[n].power_bar->setValue(sys->power_level);

            // Update the system's coolant request slider and actual allocation.
            if (coolant)
            {
                const float coolant_level = sys->coolant_level;
                unused_coolant -= coolant_level;

                systems[n].coolant_label->setText(tr("Coolant: {value}%").format({{"value", static_cast<int>(nearbyint(coolant_level * 10.0f))}}));
                systems[n].coolant_slider
                    ->setValue(std::min(sys->coolant_request, coolant->max))
                    ->setVisible(!coolant->auto_levels);
                systems[n].coolant_bar
                    ->setDrawBackground(coolant->auto_levels)
                    ->setValue(coolant_level)
                    ->setColor(coolant->auto_levels ? coolant_color_foreground : coolant_color_background)
                    ->setAttribute("margin", coolant->auto_levels ? "0, 20" : "3, 20");
            }
            else systems[n].coolant_slider->hide();

            // Update the system's heat level.
            // The bar turns redder as the heat level increases.
            const float heat_level = sys->heat_level;
            const float heat_delta = sys->getHeatingDelta();

            systems[n].heat_label->setText(tr("Heat: {value}%").format({{"value", static_cast<int>(nearbyint(heat_level * 100.0f))}}));

            systems[n].heat_bar
                ->setValue(heat_level)
                ->setColor(glm::u8vec4(128, int(128.0f * (1.0f - heat_level)), 0, 255));


            // Point the heat arrow to indicate system heat delta.
            systems[n].heat_arrow->setAngle(heat_delta > 0.0f ? 90.0f : -90.0f);
            systems[n].heat_arrow->setVisible(heat_level > 0.0f);
            systems[n].heat_arrow->setColor(glm::u8vec4(255, 255, 255, std::min(255, int(255.0f * fabs(heat_delta)))));
        }
        else systems[n].container->hide();
    }

    // Update coolant distribution and capacity gauges in the status bar.
    if (coolant)
    {
        coolant_display->setValue(tr("{unused}/{capacity}").format(
            {
                {"unused", string(int(nearbyint(unused_coolant * 100.0f / coolant->max_coolant_per_system)))},
                {"capacity", string(int(nearbyint(coolant->max * 100.0f / coolant->max_coolant_per_system)))}
            }
        ));
        coolant_distribution_gauge->setValue(unused_coolant / coolant->max);
    }
}

void PowerManagementScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        // Handle hotkeys for selecting a system to manage.
        for (int n = 0; n < ShipSystem::COUNT; n++)
        {
            if (keys.engineering_select_system[n].getDown()) selected_system = static_cast<ShipSystem::Type>(n);

            // Handle hotkeys for setting power values.
            float set_value = keys.engineering_set_power_for_system[n].getValue() * 3.0f;
            auto sys = ShipSystem::get(my_spaceship, static_cast<ShipSystem::Type>(n));

            if (sys && set_value != sys->power_request && (set_value != 0.0f || set_power_active[n]))
            {
                my_player_info->commandSetSystemPowerRequest(static_cast<ShipSystem::Type>(n), set_value);
                // Ensure the next update is sent, even if it is back to zero.
                set_power_active[n] = set_value != 0.0f;
            }

            // Handle hotkeys for setting coolant values.
            if (auto coolant = my_spaceship.getComponent<Coolant>())
            {
                set_value = keys.engineering_set_coolant_for_system[n].getValue() * coolant->max_coolant_per_system;

                if (sys && set_value != sys->coolant_request && (set_value != 0.0f || set_coolant_active[n]))
                {
                    my_player_info->commandSetSystemCoolantRequest(static_cast<ShipSystem::Type>(n), set_value);
                    // Ensure the next update is sent, even if it is back to zero.
                    set_coolant_active[n] = set_value != 0.0f;
                }
            }
        }

        // Don't act if the selected system doesn't exist.
        if (!ShipSystem::get(my_spaceship, selected_system)) return;

        // If we selected a system, check for the power/coolant modifier.
        if (selected_system != ShipSystem::Type::None)
        {
            GuiSlider* power_slider = systems[int(selected_system)].power_slider;

            // Handle hotkeys for setting power for the selected system to a given level.
            // Note code duplication with crew6/engineeringScreen.
            // Power Management should probably instead use Engineering's hotkeys for these.
            if (keys.engineering_set_power_000.getDown())
            {
                power_slider->setValue(0.0f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_030.getDown())
            {
                power_slider->setValue(0.3f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_050.getDown())
            {
                power_slider->setValue(0.5f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_100.getDown())
            {
                power_slider->setValue(1.0f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_150.getDown())
            {
                power_slider->setValue(1.5f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_200.getDown())
            {
                power_slider->setValue(2.0f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_250.getDown())
            {
                power_slider->setValue(2.5f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }
            if (keys.engineering_set_power_300.getDown())
            {
                power_slider->setValue(3.0f);
                my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
            }

            // Handle hotkeys for incremental power changes to the selected system.
            auto power_adjust = (keys.engineering_increase_power.getValue() - keys.engineering_decrease_power.getValue()) * 0.1f;
            if (power_adjust != 0.0f)
            {
                if (auto sys = ShipSystem::get(my_spaceship, selected_system))
                {
                    power_slider->setValue(sys->power_request + power_adjust);
                    my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
                }
            }

            // Handle hotkeys for incremental coolant changes to the selected system.
            GuiSlider* coolant_slider = systems[int(selected_system)].coolant_slider;
            auto coolant_adjust = (keys.engineering_increase_coolant.getValue() - keys.engineering_decrease_coolant.getValue()) * 0.5f;
            if (coolant_adjust != 0.0f)
            {
                if (auto sys = ShipSystem::get(my_spaceship, selected_system))
                {
                    coolant_slider->setValue(sys->coolant_request + coolant_adjust);
                    my_player_info->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
                }
            }
        }
    }
}
