#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "engineeringScreen.h"

#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shipInternalView.h"
#include "screenComponents/selfDestructButton.h"

EngineeringScreen::EngineeringScreen(GuiContainer* owner)
: GuiOverlay(owner, "ENGINEERING_SCREEN", sf::Color::Black), selected_system(SYS_Reactor)
{
    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, "Energy", "");
    energy_display->setTextSize(20)->setPosition(20, 100, ATopLeft)->setSize(240, 40);
    hull_display = new GuiKeyValueDisplay(this, "HULL_DISPLAY", 0.45, "Hull", "");
    hull_display->setTextSize(20)->setPosition(20, 140, ATopLeft)->setSize(240, 40);
    shields_display = new GuiKeyValueDisplay(this, "SHIELDS_DISPLAY", 0.45, "Shields", "");
    shields_display->setTextSize(20)->setPosition(20, 180, ATopLeft)->setSize(240, 40);
    
    (new GuiSelfDestructButton(this, "SELF_DESTRUCT"))->setPosition(20, 220, ATopLeft)->setSize(240, 100);
    
    GuiAutoLayout* system_row_layouts = new GuiAutoLayout(this, "SYSTEM_ROWS", GuiAutoLayout::LayoutVerticalBottomToTop);
    system_row_layouts->setPosition(20, -20, ABottomLeft);
    system_row_layouts->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    for(int n=0; n<SYS_COUNT; n++)
    {
        string id = "SYSTEM_ROW_" + getSystemName(ESystem(n));
        SystemRow info;
        info.layout = new GuiAutoLayout(system_row_layouts, id, GuiAutoLayout::LayoutHorizontalLeftToRight);
        info.layout->setSize(GuiElement::GuiSizeMax, 50);
        
        info.button = new GuiToggleButton(info.layout, id + "_SELECT", getSystemName(ESystem(n)), [this, n](bool value){
            for(int idx=0; idx<SYS_COUNT; idx++)
            {
                system_rows[idx].button->setValue(idx == n);
            }
            selected_system = ESystem(n);
            if (my_spaceship)
            {
                power_slider->setValue(my_spaceship->systems[n].power_level);
                coolant_slider->setValue(my_spaceship->systems[n].coolant_level);
            }
        });
        info.button->setSize(300, GuiElement::GuiSizeMax);
        info.damage_bar = new GuiProgressbar(info.layout, id + "_DAMAGE", 0.0, 1.0, 0.0);
        info.damage_bar->setSize(100, GuiElement::GuiSizeMax);
        if (!gameGlobalInfo->use_system_damage)
            info.damage_bar->hide();
        info.damage_label = new GuiLabel(info.damage_bar, id + "_DAMAGE_LABEL", "...", 20);
        info.damage_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        info.heat_bar = new GuiProgressbar(info.layout, id + "_HEAT", 0.0, 1.0, 0.0);
        info.heat_bar->setSize(50, GuiElement::GuiSizeMax);
        info.heat_arrow = new GuiArrow(info.heat_bar, id + "_HEAT_ARROW", 0);
        info.heat_arrow->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        info.power_bar = new GuiProgressbar(info.layout, id + "_POWER", 0.0, 3.0, 0.0);
        info.power_bar->setColor(sf::Color(192, 192, 0))->setSize(50, GuiElement::GuiSizeMax);
        info.coolant_bar = new GuiProgressbar(info.layout, id + "_COOLANT", 0.0, 10.0, 0.0);
        info.coolant_bar->setColor(sf::Color(0, 128, 128))->setSize(50, GuiElement::GuiSizeMax);
        
        info.layout->moveToBack();
        system_rows.push_back(info);
    }
    
    GuiBox* box = new GuiBox(this, "POWER_COOLANT_BOX");
    box->setPosition(110, -20, ABottomCenter)->setSize(270, 400);
    (new GuiLabel(box, "POWER_LABEL", "Power", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(20, 20, ATopLeft)->setSize(30, 360);
    (new GuiLabel(box, "COOLANT_LABEL", "Coolant", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(110, 20, ATopLeft)->setSize(30, 360);
    
    power_slider = new GuiSlider(box, "POWER_SLIDER", 3.0, 0.0, 1.0, [this](float value) {
        if (my_spaceship)
            my_spaceship->commandSetSystemPower(selected_system, value);
    });
    power_slider->setSnapValue(1.0, 0.1)->setPosition(50, 20, ATopLeft)->setSize(60, 360);
    coolant_slider = new GuiSlider(box, "COOLANT_SLIDER", 10.0, 0.0, 0.0, [this](float value) {
        if (my_spaceship)
            my_spaceship->commandSetSystemCoolant(selected_system, value);
    });
    coolant_slider->setPosition(140, 20, ATopLeft)->setSize(60, 360);

    (new GuiShieldFrequencySelect(this, "SHIELD_FREQ"))->setPosition(-20, -20, ABottomRight)->setSize(320, 400);
    
    (new GuiShipInternalView(system_row_layouts, "SHIP_INTERNAL_VIEW", 48.0f))->setShip(my_spaceship)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void EngineeringScreen::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        energy_display->setValue(string(int(my_spaceship->energy_level)) + " (" + string(my_spaceship->getNetPowerUsage()) + ")");
        hull_display->setValue(string(int(100 * my_spaceship->hull_strength / my_spaceship->hull_max)) + "%");
        shields_display->setValue(string(int(100 * my_spaceship->front_shield / my_spaceship->front_shield_max)) + "% " + string(int(100 * my_spaceship->rear_shield / my_spaceship->rear_shield_max)) + "%");
        
        for(int n=0; n<SYS_COUNT; n++)
        {
            SystemRow info = system_rows[n];
            info.layout->setVisible(my_spaceship->hasSystem(ESystem(n)));
            
            float health = my_spaceship->systems[n].health;
            if (health < 0.0)
                info.damage_bar->setValue(-health)->setColor(sf::Color(128, 32, 32));
            else
                info.damage_bar->setValue(health)->setColor(sf::Color(64, 128 * health, 64 * health));
            info.damage_label->setText(string(int(health * 100)) + "%");
            
            float heat = my_spaceship->systems[n].heat_level;
            info.heat_bar->setValue(heat)->setColor(sf::Color(128, 128 * (1.0 - heat), 0));
            float heating_diff = my_spaceship->systems[n].getHeatingDelta();
            if (heating_diff > 0)
                info.heat_arrow->setAngle(90);
            else
                info.heat_arrow->setAngle(-90);
            info.heat_arrow->setVisible(heat > 0);
            info.heat_arrow->setColor(sf::Color(255, 255, 255, std::min(255, int(255 * fabs(heating_diff)))));
            
            info.power_bar->setValue(my_spaceship->systems[n].power_level);
            info.coolant_bar->setValue(my_spaceship->systems[n].coolant_level);
        }
    }
    GuiOverlay::onDraw(window);
}
