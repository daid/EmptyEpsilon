#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "missileTubeControls.h"
#include "powerDamageIndicator.h"

#include "gui/gui2_button.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"

GuiMissileTubeControls::GuiMissileTubeControls(GuiContainer* owner, string id)
: GuiElement(owner, id), load_type(MW_None), manual_aim(false), missile_target_angle(0)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    setAttribute("layout", "verticalbottom");

    rows.resize(max_weapon_tubes);

    for (int n = max_weapon_tubes - 1; n >= 0; n--)
    {
        TubeRow row;
        row.layout = new GuiElement(this, id + "_ROW_" + string(n));
        row.layout->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
        row.load_button = new GuiButton(row.layout, id + "_" + string(n) + "_LOAD_BUTTON", "Load", [this, n]() {
            if (!my_spaceship)
                return;
            if (my_spaceship->weapon_tube[n].isEmpty())
            {
                if (load_type != MW_None)
                {
                    my_spaceship->commandLoadTube(n, load_type);
                }
            }
            else
            {
                my_spaceship->commandUnloadTube(n);
            }
        });
        row.load_button->setSize(130, 50);
        row.fire_button = new GuiButton(row.layout, id + "_" + string(n) + "_FIRE_BUTTON", "Fire", [this, n]() {
            if (!my_spaceship)
                return;
            if (my_spaceship->weapon_tube[n].isLoaded())
            {
                float target_angle = missile_target_angle;
                if (!manual_aim)
                {
                    target_angle = my_spaceship->weapon_tube[n].calculateFiringSolution(my_spaceship->getTarget());
                    if (target_angle == std::numeric_limits<float>::infinity())
                        target_angle = my_spaceship->getRotation() + my_spaceship->weapon_tube[n].getDirection();
                }
                my_spaceship->commandFireTube(n, target_angle);
            }
        });
        row.fire_button->setSize(200, 50);
        (new GuiPowerDamageIndicator(row.fire_button, id + "_" + string(n) + "_PDI", SYS_MissileSystem, sp::Alignment::CenterRight))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        row.loading_bar = new GuiProgressbar(row.layout, id + "_" + string(n) + "_PROGRESS", 0, 1.0, 0);
        row.loading_bar->setColor(glm::u8vec4(128, 128, 128, 255))->setSize(200, 50);
        row.loading_label = new GuiLabel(row.loading_bar, id + "_" + string(n) + "_PROGRESS_LABEL", "Loading", 35);
        row.loading_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        rows[n] = row;
    }

    for (int n = MW_Count-1; n >= 0; n--)
    {
        load_type_rows[n].layout = new GuiElement(this, id + "_ROW_" + string(n));
        load_type_rows[n].layout->setSize(GuiElement::GuiSizeMax, 40)->setAttribute("layout", "horizontal");

        load_type_rows[n].button = new GuiToggleButton(load_type_rows[n].layout, id + "_MW_" + string(n), getLocaleMissileWeaponName(EMissileWeapons(n)), [this, n](bool value) {
            if (value)
                load_type = EMissileWeapons(n);
            else
                load_type = MW_None;
            for(int idx = 0; idx < MW_Count; idx++)
                load_type_rows[idx].button->setValue(idx == load_type);
        });
        load_type_rows[n].button->setTextSize(28)->setSize(200, 40);
    }
    load_type_rows[MW_Homing].button->setIcon("gui/icons/weapon-homing.png");
    load_type_rows[MW_Mine].button->setIcon("gui/icons/weapon-mine.png");
    load_type_rows[MW_EMP].button->setIcon("gui/icons/weapon-emp.png");
    load_type_rows[MW_Nuke].button->setIcon("gui/icons/weapon-nuke.png");
    load_type_rows[MW_HVLI].button->setIcon("gui/icons/weapon-hvli.png");

    docked_loading_bar= new GuiProgressbar(this, id + "_DOCKED_LOADING_PROGRESS", 0, 1.0, 0);
    docked_loading_bar->setColor(glm::u8vec4(128, 128, 128, 255))->setSize(200, 50);
    docked_loading_label = new GuiLabel(docked_loading_bar, id + "_DOCKED_LOADING_PROGRESS_LABEL", "Loading", 35);
    docked_loading_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();

}

void GuiMissileTubeControls::onUpdate()
{
    if (!my_spaceship || !isVisible())
        return;
    for (int n = 0; n < MW_Count; n++)
    {
        load_type_rows[n].button->setText(getLocaleMissileWeaponName(EMissileWeapons(n)) + " [" + string(my_spaceship->weapon_storage[n]) + "/" + string(my_spaceship->weapon_storage_max[n]) + "]");
        load_type_rows[n].layout->setVisible(my_spaceship->weapon_storage_max[n] > 0);
    }

    for (int n = 0; n < my_spaceship->weapon_tube_count; n++)
    {
        WeaponTube& tube = my_spaceship->weapon_tube[n];
        rows[n].layout->show();
        if (tube.canOnlyLoad(MW_Mine))
            rows[n].fire_button->setIcon("gui/icons/weapon-mine", sp::Alignment::CenterLeft);
        else
            rows[n].fire_button->setIcon("gui/icons/missile", sp::Alignment::CenterLeft, tube.getDirection());
        if(tube.isEmpty())
        {
            rows[n].load_button->setEnable(tube.canLoad(load_type));
            rows[n].load_button->setText(tr("missile","Load"));
            rows[n].fire_button->disable()->show();
            rows[n].fire_button->setText(tube.getTubeName() + ": " + tr("missile","Empty"));
            rows[n].loading_bar->hide();
        }else if(tube.isLoaded())
        {
            rows[n].load_button->enable();
            rows[n].load_button->setText(tr("missile","Unload"));
            rows[n].fire_button->enable()->show();
            rows[n].fire_button->setText(tube.getTubeName() + ": " + getLocaleMissileWeaponName(tube.getLoadType()));
            rows[n].loading_bar->hide();
        }else if(tube.isLoading())
        {
            rows[n].load_button->disable();
            rows[n].load_button->setText(tr("missile","Load"));
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(tube.getTubeName() + ": " + getLocaleMissileWeaponName(tube.getLoadType()));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(tube.getLoadProgress());
            rows[n].loading_label->setText(tr("missile","Loading"));
        }else if(tube.isUnloading())
        {
            rows[n].load_button->disable();
            rows[n].load_button->setText(tr("missile","Unload"));
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getLocaleMissileWeaponName(tube.getLoadType()));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(tube.getUnloadProgress());
            rows[n].loading_label->setText(tr("missile","Unloading"));
        }else if(tube.isFiring())
        {
            rows[n].load_button->disable();
            rows[n].load_button->setText(tr("missile","Load"));
            rows[n].fire_button->disable()->show();
            rows[n].fire_button->setText(tr("missile","Firing"));
            rows[n].loading_bar->hide();
        }

        if (my_spaceship->current_warp > 0.0f)
        {
            rows[n].fire_button->disable();
        }
    }
    for(int n=my_spaceship->weapon_tube_count; n<max_weapon_tubes; n++)
        rows[n].layout->hide();

    if (my_spaceship->missile_resupply_delay < my_spaceship->missile_resupply_time){
        docked_loading_bar->show();
        docked_loading_label->show();
        docked_loading_bar->setValue((my_spaceship->missile_resupply_time-my_spaceship->missile_resupply_delay) / my_spaceship->missile_resupply_time);
    } else {
        docked_loading_bar->hide();
        docked_loading_label->hide();
    }

    if (keys.weapons_select_homing.getDown())
        selectMissileWeapon(MW_Homing);
    if (keys.weapons_select_nuke.getDown())
        selectMissileWeapon(MW_Nuke);
    if (keys.weapons_select_mine.getDown())
        selectMissileWeapon(MW_Mine);
    if (keys.weapons_select_emp.getDown())
        selectMissileWeapon(MW_EMP);
    if (keys.weapons_select_hvli.getDown())
        selectMissileWeapon(MW_HVLI);

    for(int n=0; n<my_spaceship->weapon_tube_count; n++)
    {
        if (keys.weapons_load_tube[n].getDown())
            my_spaceship->commandLoadTube(n, load_type);
        if (keys.weapons_unload_tube[n].getDown())
            my_spaceship->commandUnloadTube(n);
        if (keys.weapons_fire_tube[n].getDown())
        {
            float target_angle = missile_target_angle;
            if (!manual_aim)
            {
                target_angle = my_spaceship->weapon_tube[n].calculateFiringSolution(my_spaceship->getTarget());
                if (target_angle == std::numeric_limits<float>::infinity())
                    target_angle = my_spaceship->getRotation() + my_spaceship->weapon_tube[n].getDirection();
            }
            my_spaceship->commandFireTube(n, target_angle);
        }
    }
}

void GuiMissileTubeControls::setMissileTargetAngle(float angle)
{
    missile_target_angle = angle;
}

float GuiMissileTubeControls::getMissileTargetAngle()
{
    return missile_target_angle;
}

void GuiMissileTubeControls::setManualAim(bool manual)
{
    manual_aim = manual;
}

bool GuiMissileTubeControls::getManualAim()
{
    return manual_aim;
}

void GuiMissileTubeControls::selectMissileWeapon(EMissileWeapons type)
{
    load_type = type;
    for(int idx = 0; idx < MW_Count; idx++)
        load_type_rows[idx].button->setValue(idx == type);
}
