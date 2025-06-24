#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "engineeringScreen.h"
#include "i18n.h"
#include "engine.h"

#include "components/reactor.h"
#include "components/coolant.h"
#include "components/beamweapon.h"
#include "components/hull.h"
#include "components/jumpdrive.h"
#include "components/shields.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/selfdestruct.h"

#include "screenComponents/shipInternalView.h"
#include "screenComponents/selfDestructButton.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"
#include "screenComponents/infoDisplay.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_progressslider.h"
#include "gui/gui2_arrow.h"
#include "gui/gui2_image.h"
#include "gui/gui2_panel.h"

EngineeringScreen::EngineeringScreen(GuiContainer* owner, CrewPosition crew_position)
: GuiOverlay(owner, "ENGINEERING_SCREEN", colorConfig.background), selected_system(ShipSystem::Type::None)
{
    // Render the background decorations.
    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));


    auto stats = new GuiElement(this, "ENGINEER_STATS");
    stats->setPosition(20, 100, sp::Alignment::TopLeft)->setSize(240, 200)->setAttribute("layout", "vertical");

    auto energy_display = new EnergyInfoDisplay(stats, "ENERGY_DISPLAY", 0.45, true);
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setSize(240, 40);
    auto hull_display = new HullInfoDisplay(stats, "HULL_DISPLAY", 0.45);
    hull_display->setTextSize(20)->setSize(240, 40);
    auto front_shield_display = new ShieldsInfoDisplay(stats, "SHIELDS_DISPLAY", 0.45, 0);
    front_shield_display->setSize(240, 40);
    auto rear_shield_display = new ShieldsInfoDisplay(stats, "SHIELDS_DISPLAY", 0.45, 1);
    rear_shield_display->setSize(240, 40);
    auto coolant_display = new CoolantInfoDisplay(stats, "COOLANT_DISPLAY", 0.45);
    coolant_display->setSize(240, 40);

    self_destruct_button = new GuiSelfDestructButton(this, "SELF_DESTRUCT");
    self_destruct_button->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(240, 100)->setVisible(my_spaceship && my_spaceship.hasComponent<SelfDestruct>());

    GuiElement* system_config_container = new GuiElement(this, "");
    system_config_container->setPosition(0, -20, sp::Alignment::BottomCenter)->setSize(750 + 300, GuiElement::GuiSizeMax);
    GuiElement* system_row_layouts = new GuiElement(system_config_container, "SYSTEM_ROWS");
    system_row_layouts->setPosition(0, 0, sp::Alignment::BottomLeft)->setAttribute("layout", "verticalbottom");
    system_row_layouts->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    float column_width = gameGlobalInfo->use_system_damage ? 100 : 150;
    for(int n=0; n<ShipSystem::COUNT; n++)
    {
        string id = "SYSTEM_ROW_" + getSystemName(ShipSystem::Type(n));
        SystemRow info;
        info.row = new GuiElement(system_row_layouts, id);
        info.row->setAttribute("layout", "horizontal");
        info.row->setSize(GuiElement::GuiSizeMax, 50);

        info.button = new GuiToggleButton(info.row, id + "_SELECT", getLocaleSystemName(ShipSystem::Type(n)), [this, n](bool value){
            selectSystem(ShipSystem::Type(n));
        });
        info.button->setSize(300, GuiElement::GuiSizeMax);
        info.damage_bar = new GuiProgressbar(info.row, id + "_DAMAGE", 0.0f, 1.0f, 0.0f);
        info.damage_bar->setSize(150, GuiElement::GuiSizeMax);
        info.damage_icon = new GuiImage(info.damage_bar, "", "gui/icons/system_health");
        info.damage_icon->setColor(colorConfig.overlay_damaged)->setPosition(0, 0, sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMatchHeight, GuiElement::GuiSizeMax);
        info.damage_label = new GuiLabel(info.damage_bar, id + "_DAMAGE_LABEL", "...", 20);
        info.damage_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        info.heat_bar = new GuiProgressbar(info.row, id + "_HEAT", 0.0f, 1.0f, 0.0f);
        info.heat_bar->setSize(column_width, GuiElement::GuiSizeMax);
        info.heat_arrow = new GuiArrow(info.heat_bar, id + "_HEAT_ARROW", 0);
        info.heat_arrow->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        info.heat_icon = new GuiImage(info.heat_bar, "", "gui/icons/status_overheat");
        info.heat_icon->setColor(colorConfig.overlay_overheating)->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, GuiElement::GuiSizeMax);
        info.power_bar = new GuiProgressSlider(info.row, id + "_POWER", 0.0f, 3.0f, 0.0f, [this,n](float value){
            if (my_spaceship)
                my_player_info->commandSetSystemPowerRequest(ShipSystem::Type(n), value);
        });
        info.power_bar->setColor(glm::u8vec4(192, 192, 32, 128))->setSize(column_width, GuiElement::GuiSizeMax);
        info.coolant_bar = new GuiProgressSlider(info.row, id + "_COOLANT", 0.0f, 10.0f, 0.0f, [this,n](float value){
            if (my_spaceship)
                my_player_info->commandSetSystemCoolantRequest(ShipSystem::Type(n), value);
        });
        info.coolant_bar->setColor(glm::u8vec4(32, 128, 128, 128))->setSize(column_width, GuiElement::GuiSizeMax);
        if (!gameGlobalInfo->use_system_damage)
            info.damage_bar->hide();
        info.coolant_max_indicator = new GuiImage(info.coolant_bar, "", "gui/widget/SliderTick.png");
        info.coolant_max_indicator->setSize(40, 40);
        info.coolant_max_indicator->setAngle(90);
        info.coolant_max_indicator->setColor({255,255,255,0});

        info.row->moveToBack();
        system_rows.push_back(info);
    }

    GuiElement* icon_layout = new GuiElement(system_row_layouts, "");
    icon_layout->setSize(GuiElement::GuiSizeMax, 48)->setAttribute("layout", "horizontal");
    (new GuiElement(icon_layout, "FILLER"))->setSize(300, GuiElement::GuiSizeMax);
    if (gameGlobalInfo->use_system_damage)
        (new GuiImage(icon_layout, "SYSTEM_HEALTH_ICON", "gui/icons/system_health"))->setSize(150, GuiElement::GuiSizeMax);
    (new GuiImage(icon_layout, "HEAT_ICON", "gui/icons/status_overheat"))->setSize(column_width, GuiElement::GuiSizeMax);
    (new GuiImage(icon_layout, "POWER_ICON", "gui/icons/energy"))->setSize(column_width, GuiElement::GuiSizeMax);
    coolant_remaining_bar = new GuiProgressSlider(icon_layout, "", 0, 10.0, 10.0, [](float requested_unused_coolant)
    {
        float total_requested = 0.0f;
        auto coolant = my_spaceship.getComponent<Coolant>();
        if (!coolant) return;
        float new_max_total = coolant->max - requested_unused_coolant;
        for(int n=0; n<ShipSystem::COUNT; n++) {
            auto sys = ShipSystem::get(my_spaceship, ShipSystem::Type(n));
            if (sys)
                total_requested += sys->coolant_request;
        }
        if (new_max_total < total_requested) { // Drain systems
            for(int n=0; n<ShipSystem::COUNT; n++) {
                auto sys = ShipSystem::get(my_spaceship, ShipSystem::Type(n));
                if (sys)
                    my_player_info->commandSetSystemCoolantRequest(ShipSystem::Type(n), sys->coolant_request * new_max_total / total_requested);
            }
        } else { // Put coolant into systems
            int system_count = 0;
            for(int n=0; n<ShipSystem::COUNT; n++)
                if (ShipSystem::get(my_spaceship, ShipSystem::Type(n)))
                    system_count += 1;
            float add = (new_max_total - total_requested) / float(system_count);
            for(int n=0; n<ShipSystem::COUNT; n++) {
                auto sys = ShipSystem::get(my_spaceship, ShipSystem::Type(n));
                if (sys)
                    my_player_info->commandSetSystemCoolantRequest(ShipSystem::Type(n), std::min(sys->coolant_request + add, 10.0f));
            }
        }
    });
    coolant_remaining_bar->setColor(glm::u8vec4(32, 128, 128, 128))->setDrawBackground(false)->setSize(column_width, GuiElement::GuiSizeMax);
    (new GuiImage(coolant_remaining_bar, "COOLANT_ICON", "gui/icons/coolant"))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    system_rows[int(ShipSystem::Type::Reactor)].button->setIcon("gui/icons/system_reactor");
    system_rows[int(ShipSystem::Type::BeamWeapons)].button->setIcon("gui/icons/system_beam");
    system_rows[int(ShipSystem::Type::MissileSystem)].button->setIcon("gui/icons/system_missile");
    system_rows[int(ShipSystem::Type::Maneuver)].button->setIcon("gui/icons/system_maneuver");
    system_rows[int(ShipSystem::Type::Impulse)].button->setIcon("gui/icons/system_impulse");
    system_rows[int(ShipSystem::Type::Warp)].button->setIcon("gui/icons/system_warpdrive");
    system_rows[int(ShipSystem::Type::JumpDrive)].button->setIcon("gui/icons/system_jumpdrive");
    system_rows[int(ShipSystem::Type::FrontShield)].button->setIcon("gui/icons/shields-fore");
    system_rows[int(ShipSystem::Type::RearShield)].button->setIcon("gui/icons/shields-aft");

    system_effects_container = new GuiElement(system_config_container, "");
    system_effects_container->setPosition(0, -400, sp::Alignment::BottomRight)->setSize(270, 400)->setAttribute("layout", "verticalbottom");
    GuiPanel* box = new GuiPanel(system_config_container, "POWER_COOLANT_BOX");
    box->setPosition(0, 0, sp::Alignment::BottomRight)->setSize(270, 400);
    power_label = new GuiLabel(box, "POWER_LABEL", tr("slider", "Power"), 30);
    power_label->setVertical()->setAlignment(sp::Alignment::Center)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(30, 360);
    coolant_label = new GuiLabel(box, "COOLANT_LABEL", tr("slider", "Coolant"), 30);
    coolant_label->setVertical()->setAlignment(sp::Alignment::Center)->setPosition(110, 20, sp::Alignment::TopLeft)->setSize(30, 360);

    power_slider = new GuiSlider(box, "POWER_SLIDER", 3.0, 0.0, 1.0, [this](float value) {
        if (my_spaceship && selected_system != ShipSystem::Type::None)
            my_player_info->commandSetSystemPowerRequest(selected_system, value);
    });
    power_slider->setPosition(50, 20, sp::Alignment::TopLeft)->setSize(60, 360);
    for(float snap_point = 0.0f; snap_point <= 3.0f; snap_point += 0.5f)
        power_slider->addSnapValue(snap_point, snap_point == 1.0f ? 0.1f : 0.01f);
    power_slider->disable();
    coolant_slider = new GuiSlider(box, "COOLANT_SLIDER", 10.0, 0.0, 0.0, [this](float value) {
        if (my_spaceship && selected_system != ShipSystem::Type::None)
            my_player_info->commandSetSystemCoolantRequest(selected_system, value);
    });
    coolant_slider->setPosition(140, 20, sp::Alignment::TopLeft)->setSize(60, 360);
    for(float snap_point = 0.0f; snap_point <= 10.0f; snap_point += 2.5f)
        coolant_slider->addSnapValue(snap_point, 0.1f);
    coolant_slider->disable();

    (new GuiShipInternalView(system_row_layouts, "SHIP_INTERNAL_VIEW", 48.0f))->setShip(my_spaceship)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiCustomShipFunctions(this, crew_position, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void EngineeringScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        float total_coolant_used = 0.0f;
        for(int n=0; n<ShipSystem::COUNT; n++)
        {
            SystemRow info = system_rows[n];
            auto system = ShipSystem::get(my_spaceship, ShipSystem::Type(n));
            info.row->setVisible(system);
            if (!system)
                continue;

            float health = system->health;
            if (health < 0.0f)
                info.damage_bar->setValue(-health)->setColor(glm::u8vec4(128, 32, 32, 192));
            else
                info.damage_bar->setValue(health)->setColor(glm::u8vec4(64, 128 * health, 64 * health, 192));
            info.damage_label->setText(toNearbyIntString(health * 100) + "%");
            float health_max = system->health_max;
            if (health_max < 1.0f)
                info.damage_icon->show();
            else
                info.damage_icon->hide();

            float heat = system->heat_level;
            info.heat_bar->setValue(heat)->setColor(glm::u8vec4(128, 32 + 96 * (1.0f - heat), 32, 192));
            float heating_diff = system->getHeatingDelta();
            if (heating_diff > 0)
                info.heat_arrow->setAngle(90);
            else
                info.heat_arrow->setAngle(-90);
            info.heat_arrow->setVisible(heat > 0);
            info.heat_arrow->setColor(glm::u8vec4(255, 255, 255, std::min(255, int(255.0f * fabs(heating_diff)))));
            if (heat > 0.9f && fmod(engine->getElapsedTime(), 0.5f) < 0.25f)
                info.heat_icon->show();
            else
                info.heat_icon->hide();

            info.power_bar->setValue(system->power_level);
            info.coolant_bar->setValue(system->coolant_level);
            if (system->coolant_request > 0.0f) {
                float f = system->coolant_request / 10.f;
                info.coolant_max_indicator->setPosition(-20 + info.coolant_bar->getSize().x * f, 5);
                info.coolant_max_indicator->setColor({255,255,255,255});
            } else {
                info.coolant_max_indicator->setColor({255,255,255,0});
            }
            total_coolant_used += system->coolant_level;
        }

        auto coolant = my_spaceship.getComponent<Coolant>();
        coolant_remaining_bar->setVisible(coolant);
        if (coolant) {
            coolant_remaining_bar->setRange(0, coolant->max);
            coolant_remaining_bar->setValue(coolant->max - total_coolant_used);
        }

        if (selected_system != ShipSystem::Type::None)
        {
            auto system = ShipSystem::get(my_spaceship, selected_system);
            if (system) {
                power_label->setText(tr("slider", "Power: {current_level}% / {requested}%").format({{"current_level", toNearbyIntString(system->power_level * 100)}, {"requested", toNearbyIntString(system->power_request * 100)}}));
                power_slider->setValue(system->power_request);
                coolant_label->setVisible(coolant);
                coolant_slider->setVisible(coolant);
                if (coolant) {
                    coolant_label->setText(tr("slider", "Coolant: {current_level}% / {requested}%").format({{"current_level", toNearbyIntString(system->coolant_level / coolant->max_coolant_per_system * 100.0f)}, {"requested", toNearbyIntString(std::min(system->coolant_request, coolant->max) / coolant->max_coolant_per_system * 100)}}));
                    coolant_slider->setEnable(!coolant->auto_levels);
                    coolant_slider->setValue(std::min(system->coolant_request, coolant->max));
                }

                system_effects_index = 0;
                float effectiveness = system->getSystemEffectiveness();
                float health_max = system->health_max;
                if (health_max < 1.0f)
                    addSystemEffect(tr("Engineer", "Maximal health"), toNearbyIntString(health_max * 100) + "%");
                switch(selected_system)
                {
                case ShipSystem::Type::Reactor:
                    if (effectiveness > 1.0f)
                        effectiveness = (1.0f + effectiveness) / 2.0f;
                    addSystemEffect(tr("Energy production"),  tr("{energy}/min").format({{"energy", string(effectiveness * -system->power_factor * system->power_factor_rate * 60.0f, 1)}}));
                    break;
                case ShipSystem::Type::BeamWeapons:
                    addSystemEffect(tr("Firing rate"), toNearbyIntString(effectiveness * 100) + "%");
                    // If the ship has a turret, also note that the rotation rate
                    // is affected.
                    if (auto beamweapons = my_spaceship.getComponent<BeamWeaponSys>()) {
                        for(auto& mount : beamweapons->mounts) {
                            if (mount.turret_arc > 0) {
                                addSystemEffect(tr("Engineer", "Turret rotation rate"), toNearbyIntString(effectiveness * 100) + "%");
                                break;
                            }
                        }
                    }
                    break;
                case ShipSystem::Type::MissileSystem:
                    addSystemEffect(tr("missile","Reload rate"), toNearbyIntString(effectiveness * 100) + "%");
                    break;
                case ShipSystem::Type::Maneuver:{
                    addSystemEffect(tr("Turning speed"), toNearbyIntString(effectiveness * 100) + "%");
                    auto combat = my_spaceship.getComponent<CombatManeuveringThrusters>();
                    if (combat) {
                        auto impulse = my_spaceship.getComponent<ImpulseEngine>();
                        auto thrusters = my_spaceship.getComponent<ManeuveringThrusters>();
                        if (impulse && thrusters)
                            addSystemEffect(tr("Combat recharge rate"), toNearbyIntString(((impulse->getSystemEffectiveness() + thrusters->getSystemEffectiveness()) / 2.0f) * 100) + "%");
                    }
                    }break;
                case ShipSystem::Type::Impulse:{
                    addSystemEffect(tr("Impulse speed"), toNearbyIntString(effectiveness * 100) + "%");
                    auto combat = my_spaceship.getComponent<CombatManeuveringThrusters>();
                    if (combat) {
                        auto impulse = my_spaceship.getComponent<ImpulseEngine>();
                        auto thrusters = my_spaceship.getComponent<ManeuveringThrusters>();
                        if (impulse && thrusters)
                            addSystemEffect(tr("Combat recharge rate"), toNearbyIntString(((impulse->getSystemEffectiveness() + thrusters->getSystemEffectiveness()) / 2.0f) * 100) + "%");
                    }
                    }break;
                case ShipSystem::Type::Warp:
                    addSystemEffect(tr("Warp drive speed"), toNearbyIntString(effectiveness * 100) + "%");
                    break;
                case ShipSystem::Type::JumpDrive:{
                    if (auto jump = my_spaceship.getComponent<JumpDrive>()) {
                        if (jump->get_seconds_to_jump() == std::numeric_limits<int>::max())
                            addSystemEffect(tr("Time to jump activation"), "∞ sec.");
                        else
                            addSystemEffect(tr("Time to jump activation"), tr("jumpcontrol", "{delay} sec.").format({{"delay", string(jump->get_seconds_to_jump())}}));
                        addSystemEffect(tr("Jump drive recharge rate"), toNearbyIntString(jump->get_recharge_rate() * 100) + "%");
                    }
                    }break;
                case ShipSystem::Type::FrontShield:{
                    auto shields = my_spaceship.getComponent<Shields>();
                    if (shields) {
                        if (gameGlobalInfo->use_beam_shield_frequencies)
                            addSystemEffect(tr("shields","Calibration speed"), toNearbyIntString((shields->front_system.getSystemEffectiveness() + shields->rear_system.getSystemEffectiveness()) / 2.0f * 100) + "%");
                        addSystemEffect(tr("shields","Charge rate"), toNearbyIntString(effectiveness * 100) + "%");
                        {
                            DamageInfo di;
                            di.type = DamageType::Kinetic;
                            float damage_negate = 1.0f - shields->getDamageFactor(0);
                            if (damage_negate < 0.0f)
                                addSystemEffect(tr("Extra damage"), toNearbyIntString(-damage_negate * 100) + "%");
                            else
                                addSystemEffect(tr("Damage negate"), toNearbyIntString(damage_negate * 100) + "%");
                        }
                    }
                    }break;
                case ShipSystem::Type::RearShield:{
                    auto shields = my_spaceship.getComponent<Shields>();
                    if (shields) {
                        if (gameGlobalInfo->use_beam_shield_frequencies)
                            addSystemEffect(tr("shields","Calibration speed"), toNearbyIntString((shields->front_system.getSystemEffectiveness() + shields->rear_system.getSystemEffectiveness()) / 2.0f * 100) + "%");
                        addSystemEffect(tr("shields","Charge rate"), toNearbyIntString(effectiveness * 100) + "%");
                        {
                            DamageInfo di;
                            di.type = DamageType::Kinetic;
                            float damage_negate = 1.0f - shields->getDamageFactor(shields->entries.size() - 1);
                            if (damage_negate < 0.0f)
                                addSystemEffect(tr("Extra damage"), toNearbyIntString(-damage_negate * 100) + "%");
                            else
                                addSystemEffect(tr("Damage negate"), toNearbyIntString(damage_negate * 100) + "%");
                        }
                    }
                    }break;
                default:
                    break;
                }
                for(unsigned int idx=system_effects_index; idx<system_effects.size(); idx++)
                    system_effects[idx]->hide();
            }
        }
    }
    GuiOverlay::onDraw(renderer);
}

void EngineeringScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        auto coolant = my_spaceship.getComponent<Coolant>();
        for(unsigned int n=0; n<ShipSystem::COUNT; n++) {
            if (keys.engineering_select_system[n].getDown()) selectSystem(static_cast<ShipSystem::Type>(n));

            float set_value = keys.engineering_set_power_for_system[n].getValue() * 3.0f;
            auto sys = ShipSystem::get(my_spaceship, static_cast<ShipSystem::Type>(n));
            if (sys && set_value != sys->power_request && (set_value != 0.0f || set_power_active[n]))
            {
                my_player_info->commandSetSystemPowerRequest(static_cast<ShipSystem::Type>(n), set_value);
                set_power_active[n] = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
            }
            if (coolant) {
                set_value = keys.engineering_set_coolant_for_system[n].getValue() * coolant->max_coolant_per_system;
                if (sys && set_value != sys->coolant_request && (set_value != 0.0f || set_coolant_active[n]))
                {
                    my_player_info->commandSetSystemCoolantRequest(static_cast<ShipSystem::Type>(n), set_value);
                    set_coolant_active[n] = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
                }
            }
        }

        int navigate_system = keys.engineering_select_system_next.getDown() - keys.engineering_select_system_prev.getDown(); // +1 or -1
        if (navigate_system)
        {
            int n = static_cast<int>(selected_system);
            ShipSystem::Type sys = ShipSystem::Type::None;
            do
            {
                n = (n + navigate_system) % ShipSystem::COUNT;
                if (n < 0) n = ShipSystem::COUNT -1;
                sys = static_cast<ShipSystem::Type>(n);
            } while (ShipSystem::get(my_spaceship, sys) == nullptr); // endless loop if ship does not have any system!
            selectSystem(sys);
        }

        if (selected_system != ShipSystem::Type::None)
        {
            // Note the code duplication with extra/powerManagement
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

            auto power_adjust = (keys.engineering_increase_power.getValue() - keys.engineering_decrease_power.getValue()) * 0.1f;
            if (power_adjust != 0.0f)
            {
                auto sys = ShipSystem::get(my_spaceship, selected_system);
                if (sys) {
                    power_slider->setValue(sys->power_request + power_adjust);
                    my_player_info->commandSetSystemPowerRequest(selected_system, power_slider->getValue());
                }
            }
            auto coolant_adjust = (keys.engineering_increase_coolant.getValue() - keys.engineering_decrease_coolant.getValue()) * 0.5f;
            if (coolant_adjust != 0.0f)
            {
                auto sys = ShipSystem::get(my_spaceship, selected_system);
                if (sys) {
                    coolant_slider->setValue(sys->coolant_request + coolant_adjust);
                    my_player_info->commandSetSystemCoolantRequest(selected_system, coolant_slider->getValue());
                }
            }

            float set_value = keys.engineering_set_power.getValue() * 3.0f;
            auto sys = ShipSystem::get(my_spaceship, selected_system);
            if (sys && set_value != sys->power_request && (set_value != 0.0f || set_power_active[static_cast<int>(selected_system)]))
            {
                my_player_info->commandSetSystemPowerRequest(selected_system, set_value);
                set_power_active[static_cast<int>(selected_system)] = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
            }
            if (coolant && sys) {
                set_value = keys.engineering_set_coolant.getValue() * coolant->max_coolant_per_system;
                if (set_value != sys->coolant_request && (set_value != 0.0f || set_coolant_active[static_cast<int>(selected_system)]))
                {
                    my_player_info->commandSetSystemCoolantRequest(selected_system, set_value);
                    set_coolant_active[static_cast<int>(selected_system)] = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
                }
            }
        }
    }
}

void EngineeringScreen::selectSystem(ShipSystem::Type system)
{
    if (!my_spaceship || !ShipSystem::get(my_spaceship, system))
        return;

    for(int idx=0; idx<ShipSystem::COUNT; idx++)
    {
        system_rows[idx].button->setValue(ShipSystem::Type(idx) == system);
    }
    selected_system = system;
    power_slider->enable();
    if (my_spaceship)
    {
        auto sys = ShipSystem::get(my_spaceship, system);
        if (sys) {
            power_slider->setValue(sys->power_request);
            coolant_slider->setValue(sys->coolant_request);
        }
    }
}

void EngineeringScreen::addSystemEffect(string key, string value)
{
    if (system_effects_index == system_effects.size())
    {
        GuiKeyValueDisplay* item = new GuiKeyValueDisplay(system_effects_container, "", 0.7, key, value);
        item->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 40);
        system_effects.push_back(item);
    }else{
        system_effects[system_effects_index]->setKey(key);
        system_effects[system_effects_index]->setValue(value);
        system_effects[system_effects_index]->show();
    }
    system_effects_index++;
}

string EngineeringScreen::toNearbyIntString(float value)
{
    return string(int(nearbyint(value)));
}
