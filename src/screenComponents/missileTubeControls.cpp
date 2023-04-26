#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "missileTubeControls.h"
#include "powerDamageIndicator.h"
#include "components/warpdrive.h"
#include "components/missiletubes.h"
#include "components/collision.h"
#include "components/target.h"
#include "systems/missilesystem.h"

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
            if (!my_spaceship) return;
            auto tubes = my_spaceship.getComponent<MissileTubes>();
            if (!tubes) return;
            if (tubes->mounts[n].state == MissileTubes::MountPoint::State::Empty)
            {
                if (load_type != MW_None)
                {
                    my_player_info->commandLoadTube(n, load_type);
                }
            }
            else
            {
                my_player_info->commandUnloadTube(n);
            }
        });
        row.load_button->setSize(130, 50);
        row.fire_button = new GuiButton(row.layout, id + "_" + string(n) + "_FIRE_BUTTON", "Fire", [this, n]() {
            if (!my_spaceship) return;
            auto tubes = my_spaceship.getComponent<MissileTubes>();
            if (!tubes) return;
            if (tubes->mounts[n].state == MissileTubes::MountPoint::State::Loaded)
            {
                float target_angle = missile_target_angle;
                if (!manual_aim) {
                    auto target = my_spaceship.getComponent<Target>();
                    target_angle = MissileSystem::calculateFiringSolution(my_spaceship, tubes->mounts[n], target ? target->entity : sp::ecs::Entity{});
                    if (target_angle == std::numeric_limits<float>::infinity()) {
                        auto transform = my_spaceship.getComponent<sp::Transform>();
                        target_angle = (transform ? transform->getRotation() : 0.0f) + tubes->mounts[n].direction;
                    }
                }
                my_player_info->commandFireTube(n, target_angle);
            }
        });
        row.fire_button->setSize(200, 50);
        (new GuiPowerDamageIndicator(row.fire_button, id + "_" + string(n) + "_PDI", ShipSystem::Type::MissileSystem, sp::Alignment::CenterRight))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
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
}

static string getTubeName(float direction)
{
    if (std::abs(angleDifference(0.0f, direction)) <= 45)
        return tr("tube","Front");
    if (std::abs(angleDifference(90.0f, direction)) < 45)
        return tr("tube","Right");
    if (std::abs(angleDifference(-90.0f, direction)) < 45)
        return tr("tube","Left");
    if (std::abs(angleDifference(180.0f, direction)) <= 45)
        return tr("tube","Rear");
    return "?" + string(direction);
}

void GuiMissileTubeControls::onUpdate()
{
    if (!my_spaceship || !isVisible())
        return;
    auto tubes = my_spaceship.getComponent<MissileTubes>();
    if (!tubes) return;
    for (int n = 0; n < MW_Count; n++)
    {
        load_type_rows[n].button->setText(getLocaleMissileWeaponName(EMissileWeapons(n)) + " [" + string(tubes->storage[n]) + "/" + string(tubes->storage_max[n]) + "]");
        load_type_rows[n].layout->setVisible(tubes->storage_max[n] > 0);
    }

    for (int n = 0; n < tubes->count; n++)
    {
        auto& tube = tubes->mounts[n];
        rows[n].layout->show();
        if (tube.canOnlyLoad(MW_Mine))
            rows[n].fire_button->setIcon("gui/icons/weapon-mine", sp::Alignment::CenterLeft);
        else
            rows[n].fire_button->setIcon("gui/icons/missile", sp::Alignment::CenterLeft, tube.direction);
        switch(tube.state)
        {
        case MissileTubes::MountPoint::State::Empty:
            rows[n].load_button->setEnable(tube.canLoad(load_type));
            rows[n].load_button->setText(tr("missile","Load"));
            rows[n].fire_button->disable()->show();
            rows[n].fire_button->setText(getTubeName(tube.direction) + ": " + tr("missile","Empty"));
            rows[n].loading_bar->hide();
            break;
        case MissileTubes::MountPoint::State::Loaded:
            rows[n].load_button->enable();
            rows[n].load_button->setText(tr("missile","Unload"));
            rows[n].fire_button->enable()->show();
            rows[n].fire_button->setText(getTubeName(tube.direction) + ": " + getLocaleMissileWeaponName(tube.type_loaded));
            rows[n].loading_bar->hide();
            break;
        case MissileTubes::MountPoint::State::Loading:
            rows[n].load_button->disable();
            rows[n].load_button->setText(tr("missile","Load"));
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getTubeName(tube.direction) + ": " + getLocaleMissileWeaponName(tube.type_loaded));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(1.0f - tube.delay / tube.load_time);
            rows[n].loading_label->setText(tr("missile","Loading"));
            break;
        case MissileTubes::MountPoint::State::Unloading:
            rows[n].load_button->disable();
            rows[n].load_button->setText(tr("missile","Unload"));
            rows[n].fire_button->hide();
            rows[n].fire_button->setText(getLocaleMissileWeaponName(tube.type_loaded));
            rows[n].loading_bar->show();
            rows[n].loading_bar->setValue(tube.delay / tube.load_time);
            rows[n].loading_label->setText(tr("missile","Unloading"));
            break;
        case MissileTubes::MountPoint::State::Firing:
            rows[n].load_button->disable();
            rows[n].load_button->setText(tr("missile","Load"));
            rows[n].fire_button->disable()->show();
            rows[n].fire_button->setText(tr("missile","Firing"));
            rows[n].loading_bar->hide();
        }

        auto warp = my_spaceship.getComponent<WarpDrive>();
        if (warp && warp->current > 0.0f)
        {
            rows[n].fire_button->disable();
        }
    }
    for(int n=tubes->count; n<max_weapon_tubes; n++)
        rows[n].layout->hide();

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

    for(int n=0; n<tubes->count; n++)
    {
        if (keys.weapons_load_tube[n].getDown())
            my_player_info->commandLoadTube(n, load_type);
        if (keys.weapons_unload_tube[n].getDown())
            my_player_info->commandUnloadTube(n);
        if (keys.weapons_fire_tube[n].getDown())
        {
            float target_angle = missile_target_angle;
            if (!manual_aim)
            {
                auto target = my_spaceship.getComponent<Target>();
                target_angle = MissileSystem::calculateFiringSolution(my_spaceship, tubes->mounts[n], target ? target->entity : sp::ecs::Entity{});
                if (target_angle == std::numeric_limits<float>::infinity()) {
                    auto transform = my_spaceship.getComponent<sp::Transform>();
                    target_angle = (transform ? transform->getRotation() : 0.0f) + tubes->mounts[n].direction;
                }
            }
            my_player_info->commandFireTube(n, target_angle);
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
