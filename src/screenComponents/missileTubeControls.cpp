#include "playerInfo.h"
#include "missileTubeControls.h"
#include "powerDamageIndicator.h"

GuiMissileTubeControls::GuiMissileTubeControls(GuiContainer* owner, string id)
: GuiAutoLayout(owner, id, LayoutVerticalBottomToTop), load_type(MW_None), missile_target_angle(0)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    for(int n=0; n<max_weapon_tubes; n++)
    {
        TubeRow row;
        row.layout = new GuiAutoLayout(this, id + "_ROW_" + string(n), LayoutHorizontalLeftToRight);
        row.layout->setSize(GuiElement::GuiSizeMax, 50);
        row.load_button = new GuiButton(row.layout, id + "_" + string(n) + "_LOAD_BUTTON", "Load", [this, n]() {
            if (!my_spaceship || load_type == MW_None)
                return;
            if (my_spaceship->weapon_tube[n].isEmpty())
                my_spaceship->commandLoadTube(n, load_type);
            else
                my_spaceship->commandUnloadTube(n);
        });
        row.load_button->setSize(150, 50);
        row.fire_button = new GuiButton(row.layout, id + "_" + string(n) + "_FIRE_BUTTON", "Fire", [this, n]() {
            if (!my_spaceship)
                return;
            if (my_spaceship->weapon_tube[n].isLoaded())
                my_spaceship->commandFireTube(n, missile_target_angle);
        });
        row.fire_button->setSize(350, 50);
        (new GuiPowerDamageIndicator(row.fire_button, id + "_" + string(n) + "_PDI", SYS_MissileSystem))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        row.loading_bar = new GuiProgressbar(row.layout, id + "_" + string(n) + "_PROGRESS", 0, 1.0, 0);
        row.loading_bar->setColor(sf::Color(128, 128, 128))->setSize(350, 50);
        row.loading_label = new GuiLabel(row.loading_bar, id + "_" + string(n) + "_PROGRESS_LABEL", "Loading", 35);
        row.loading_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        
        rows.push_back(row);
    }
    
    
    
    
    
    for(int n=MW_Count-1; n>=0; n--)
    {
        GuiAutoLayout* row = new GuiAutoLayout(this, id + "_ROW_" + string(n), LayoutHorizontalLeftToRight);
        row->setSize(GuiElement::GuiSizeMax, 40);
        
        load_type_buttons[n] = new GuiToggleButton(row, id + "_MW_" + string(n), getMissileWeaponName(EMissileWeapons(n)), [this, n](bool value) {
            if (value)
                load_type = EMissileWeapons(n);
            else
                load_type = MW_None;
            for(int idx=0; idx<MW_Count; idx++)
                load_type_buttons[idx]->setValue(idx == load_type);
        });
        load_type_buttons[n]->setTextSize(28)->setSize(220, 40);
    }
}

void GuiMissileTubeControls::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;
    for(int n=0; n<MW_Count; n++)
        load_type_buttons[n]->setText(getMissileWeaponName(EMissileWeapons(n)) + " [" + string(my_spaceship->weapon_storage[n]) + "/" + string(my_spaceship->weapon_storage_max[n]) + "]");
    
    for(int n=0; n<my_spaceship->weapon_tubes; n++)
    {
        rows[n].layout->show();
        if(my_spaceship->weapon_tube[n].isEmpty())
        {
            rows[n].load_button->enable();
            rows[n].load_button->setText("Load");
            rows[n].fire_button->disable()->show();
            rows[n].fire_button->setText("Empty");
            rows[n].loading_bar->hide();
        }else if(my_spaceship->weapon_tube[n].isLoaded())
        {
            rows[n].load_button->enable();
            rows[n].load_button->setText("Unload");
            rows[n].fire_button->enable()->show();
            rows[n].fire_button->setText(getMissileWeaponName(my_spaceship->weapon_tube[n].getLoadType()));
            rows[n].loading_bar->hide();
        }else if(my_spaceship->weapon_tube[n].isLoading())
        {
            rows[n].load_button->disable();
            rows[n].load_button->setText("Load");
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getMissileWeaponName(my_spaceship->weapon_tube[n].getLoadType()));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(my_spaceship->weapon_tube[n].getLoadProgress());
            rows[n].loading_label->setText("Loading");
        }else if(my_spaceship->weapon_tube[n].isUnloading())
        {
            rows[n].load_button->disable();
            rows[n].load_button->setText("Unload");
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getMissileWeaponName(my_spaceship->weapon_tube[n].getLoadType()));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(my_spaceship->weapon_tube[n].getUnloadProgress());
            rows[n].loading_label->setText("Unloading");
        }
    }
    for(int n=my_spaceship->weapon_tubes; n<max_weapon_tubes; n++)
        rows[n].layout->hide();
    GuiAutoLayout::onDraw(window);
}

void GuiMissileTubeControls::setMissileTargetAngle(float angle)
{
    missile_target_angle = angle;
}
