#include "playerInfo.h"
#include "missileTubeControls.h"

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
            if (my_spaceship->weaponTube[n].state == WTS_Empty)
                my_spaceship->commandLoadTube(n, load_type);
            else
                my_spaceship->commandUnloadTube(n);
        });
        row.load_button->setSize(150, 50);
        row.fire_button = new GuiButton(row.layout, id + "_" + string(n) + "_FIRE_BUTTON", "Fire", [this, n]() {
            if (!my_spaceship || load_type == MW_None)
                return;
            if (my_spaceship->weaponTube[n].state == WTS_Loaded)
                my_spaceship->commandFireTube(n, missile_target_angle);
        });
        row.fire_button->setSize(350, 50);
        row.loading_bar = new GuiProgressbar(row.layout, id + "_" + string(n) + "_PROGRESS", 0, 1.0, 0);
        row.loading_bar->setColor(sf::Color(128, 128, 128))->setSize(350, 50);
        row.loading_label = new GuiLabel(row.loading_bar, id + "_" + string(n) + "_PROGRESS_LABEL", "Loading", 35);
        row.loading_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        
        rows.push_back(row);
    }
    
    for(int n=MW_Count-1; n>=0; n--)
    {
        GuiAutoLayout* row = new GuiAutoLayout(this, id + "_ROW_" + string(n), LayoutHorizontalLeftToRight);
        row->setSize(GuiElement::GuiSizeMax, 30);
        
        load_type_buttons[n] = new GuiToggleButton(row, id + "_MW_" + string(n), getMissileWeaponName(EMissileWeapons(n)), [this, n](bool value) {
            if (value)
                load_type = EMissileWeapons(n);
            else
                load_type = MW_None;
            for(int idx=0; idx<MW_Count; idx++)
                load_type_buttons[idx]->setValue(idx == load_type);
        });
        load_type_buttons[n]->setTextSize(25)->setSize(200, 30);
    }
}

void GuiMissileTubeControls::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;
    
    for(int n=0; n<my_spaceship->weapon_tubes; n++)
    {
        rows[n].layout->show();
        switch(my_spaceship->weaponTube[n].state)
        {
        case WTS_Empty:
            rows[n].load_button->enable();
            rows[n].load_button->setText("Load");
            rows[n].fire_button->disable()->show();
            rows[n].fire_button->setText("Empty");
            rows[n].loading_bar->hide();
            break;
        case WTS_Loaded:
            rows[n].load_button->enable();
            rows[n].load_button->setText("Unload");
            rows[n].fire_button->enable()->show();
            rows[n].fire_button->setText(getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded));
            rows[n].loading_bar->hide();
            break;
        case WTS_Loading:
            rows[n].load_button->disable();
            rows[n].load_button->setText("Load");
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(1.0 - my_spaceship->weaponTube[n].delay / my_spaceship->tube_load_time);
            rows[n].loading_label->setText("Loading");
            break;
        case WTS_Unloading:
            rows[n].load_button->disable();
            rows[n].load_button->setText("Unload");
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getMissileWeaponName(my_spaceship->weaponTube[n].type_loaded));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(my_spaceship->weaponTube[n].delay / my_spaceship->tube_load_time);
            rows[n].loading_label->setText("Unloading");
            break;
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
