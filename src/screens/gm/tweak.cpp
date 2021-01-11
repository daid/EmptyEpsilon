#include <i18n.h>
#include "tweak.h"
#include "playerInfo.h"
#include "spaceObjects/spaceship.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_togglebutton.h"

GuiObjectTweak::GuiObjectTweak(GuiContainer* owner, ETweakType tweak_type)
: GuiPanel(owner, "GM_TWEAK_DIALOG")
{
    setPosition(0, -100, ABottomCenter);
    setSize(1000, 600);

    GuiListbox* list = new GuiListbox(this, "", [this](int index, string value)
    {
        for(GuiTweakPage* page : pages)
            page->hide();
        pages[index]->show();
    });

    list->setSize(300, GuiElement::GuiSizeMax);
    list->setPosition(25, 25, ATopLeft);

    pages.push_back(new GuiObjectTweakBase(this));
    list->addEntry(tr("tab", "Base"), "");

    if (tweak_type == TW_Ship || tweak_type == TW_Player)
    {
        pages.push_back(new GuiTweakShip(this));
        list->addEntry(tr("tab", "Ship"), "");
    }

    if (tweak_type == TW_Asteroid)
    {
        pages.push_back(new GuiAsteroidTweak(this));
        list->addEntry(tr("tab","Asteroid"), "");
    }

    if (tweak_type == TW_Jammer)
    {
        pages.push_back(new GuiJammerTweak(this));
        list->addEntry(tr("tab", "Jammer"), "");
    }

    if (tweak_type == TW_Ship || tweak_type == TW_Player || tweak_type == TW_Station)
    {
        pages.push_back(new GuiShipTweakShields(this));
        list->addEntry(tr("tab", "Shields"), "");
    }

    if (tweak_type == TW_Ship || tweak_type == TW_Player)
    {
        pages.push_back(new GuiShipTweakMissileTubes(this));
        list->addEntry(tr("tab", "Tubes"), "");
        pages.push_back(new GuiShipTweakMissileWeapons(this));
        list->addEntry(tr("tab", "Missiles"), "");
        pages.push_back(new GuiShipTweakBeamweapons(this));
        list->addEntry(tr("tab", "Beams"), "");
        pages.push_back(new GuiShipTweakSystems(this));
        list->addEntry(tr("tab", "Systems"), "");
    }

    if (tweak_type == TW_Player)
    {
        pages.push_back(new GuiShipTweakPlayer(this));
        list->addEntry(tr("tab", "Player"), "");
        pages.push_back(new GuiShipTweakPlayer2(this));
        list->addEntry(tr("tab", "Player 2"), "");
    }

    for(GuiTweakPage* page : pages)
    {
        page->setSize(700, 600)->setPosition(0, 0, ABottomRight)->hide();
    }

    pages[0]->show();
    list->setSelectionIndex(0);

    (new GuiButton(this, "CLOSE_BUTTON", tr("button", "Close"), [this]() {
        hide();
    }))->setTextSize(20)->setPosition(-10, 0, ATopRight)->setSize(70, 30);
}

void GuiObjectTweak::open(P<SpaceObject> target)
{
    this->target = target;

    for(GuiTweakPage* page : pages)
        page->open(target);

    show();
}

void GuiObjectTweak::onDraw(sf::RenderTarget& window)
{
    GuiPanel::onDraw(window);

    if (!target)
        hide();
}

GuiTweakShip::GuiTweakShip(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    // Left column
    (new GuiLabel(left_col, "", tr("Impulse speed:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    impulse_speed_slider = new GuiSlider(left_col, "", 0.0, 250, 0.0, [this](float value) {
        target->impulse_max_speed = value;
    });
    impulse_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Turn speed:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    turn_speed_slider = new GuiSlider(left_col, "", 0.0, 35, 0.0, [this](float value) {
        target->turn_speed = value;
    });
    turn_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Jump Min Distance:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    jump_min_distance_slider= new GuiSlider(left_col, "", 0.0, 100000, 0.0, [this](float value) {
        target->setJumpDriveRange(value,target->jump_drive_max_distance);
    });
    jump_min_distance_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Jump Max Distance:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    jump_max_distance_slider= new GuiSlider(left_col, "", 0.0, 100000, 0.0, [this](float value) {
        target->setJumpDriveRange(target->jump_drive_min_distance,value);
    });
    jump_max_distance_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Jump charge:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    jump_charge_slider = new GuiSlider(left_col, "", 0.0, 100000, 0.0, [this](float value) {
        target->setJumpDriveCharge(value);
    });
    jump_charge_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    // Right column
    // Set type name. Does not change ship type.
    (new GuiLabel(right_col, "", tr("Type name:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    type_name = new GuiTextEntry(right_col, "", "");
    type_name->setSize(GuiElement::GuiSizeMax, 50);
    type_name->callback([this](string text) {
        target->setTypeName(text);
    });

    // Hull max and state sliders
    (new GuiLabel(right_col, "", tr("Hull max:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    hull_max_slider = new GuiSlider(right_col, "", 0.0, 500, 0.0, [this](float value) {
        target->hull_max = round(value);
        target->hull_strength = std::min(target->hull_strength, target->hull_max);
    });
    hull_max_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", tr("Hull current:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    hull_slider = new GuiSlider(right_col, "", 0.0, 500, 0.0, [this](float value) {
        target->hull_strength = std::min(roundf(value), target->hull_max);
    });
    hull_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

   // Can be destroyed bool
   can_be_destroyed_toggle = new GuiToggleButton(right_col, "", tr("Could be destroyed"), [this](bool value) {
       target->setCanBeDestroyed(value);
   });
   can_be_destroyed_toggle->setSize(GuiElement::GuiSizeMax, 40);

    // Warp and jump drive toggles
    (new GuiLabel(right_col, "", "Special drives:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    warp_toggle = new GuiToggleButton(right_col, "", tr("Warp Drive"), [this](bool value) {
        target->setWarpDrive(value);
    });
    warp_toggle->setSize(GuiElement::GuiSizeMax, 40);

    jump_toggle = new GuiToggleButton(right_col, "", tr("Jump Drive"), [this](bool value) {
        target->setJumpDrive(value);
    });
    jump_toggle->setSize(GuiElement::GuiSizeMax, 40);
}

void GuiTweakShip::onDraw(sf::RenderTarget& window)
{
    hull_slider->setValue(target->hull_strength);
    jump_charge_slider->setValue(target->getJumpDriveCharge());
    jump_min_distance_slider->setValue(target->jump_drive_min_distance);
    jump_max_distance_slider->setValue(target->jump_drive_max_distance);
    type_name->setText(target->getTypeName());
    warp_toggle->setValue(target->has_warp_drive);
    jump_toggle->setValue(target->hasJumpDrive());
    impulse_speed_slider->setValue(target->impulse_max_speed);
    turn_speed_slider->setValue(target->turn_speed);
    hull_max_slider->setValue(target->hull_max);
    can_be_destroyed_toggle->setValue(target->getCanBeDestroyed());
}

void GuiTweakShip::open(P<SpaceObject> target)
{
    P<SpaceShip> ship = target;
    this->target = ship;

    impulse_speed_slider->clearSnapValues()->addSnapValue(ship->ship_template->impulse_speed, 5.0f);
    turn_speed_slider->clearSnapValues()->addSnapValue(ship->ship_template->turn_speed, 1.0f);
    hull_max_slider->clearSnapValues()->addSnapValue(ship->ship_template->hull, 5.0f);
}

GuiShipTweakMissileWeapons::GuiShipTweakMissileWeapons(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    // Left column
    (new GuiLabel(left_col, "", tr("missiles", "Storage space:"), 30))->setSize(GuiElement::GuiSizeMax, 40);

    for(int n=0; n<MW_Count; n++)
    {
        (new GuiLabel(left_col, "", getLocaleMissileWeaponName(EMissileWeapons(n)) + ":", 20))->setSize(GuiElement::GuiSizeMax, 30);
        missile_storage_amount_slider[n] = new GuiSlider(left_col, "", 0.0, 50, 0.0, [this, n](float value) {
            target->weapon_storage_max[n] = int(round(value));
            target->weapon_storage[n] = std::min(target->weapon_storage[n], target->weapon_storage_max[n]);
        });
        missile_storage_amount_slider[n]->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
    }

    // Right column
    (new GuiLabel(right_col, "", tr("missiles", "Stored amount:"), 30))->setSize(GuiElement::GuiSizeMax, 40);

    for(int n=0; n<MW_Count; n++)
    {
        (new GuiLabel(right_col, "", getLocaleMissileWeaponName(EMissileWeapons(n)) + ":", 20))->setSize(GuiElement::GuiSizeMax, 30);
        missile_current_amount_slider[n] = new GuiSlider(right_col, "", 0.0, 50, 0.0, [this, n](float value) {
            target->weapon_storage[n] = std::min(int(round(value)), target->weapon_storage_max[n]);
        });
        missile_current_amount_slider[n]->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
    }
}

GuiJammerTweak::GuiJammerTweak(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    (new GuiLabel(left_col, "", tr("Jammer Range:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    jammer_range_slider = new GuiSlider(left_col, "", 0, 50000, 0, [this](float value) {
        target->setRange(round(value/100)*100);
    });
    jammer_range_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
}

void GuiJammerTweak::open(P<SpaceObject> target)
{
    P<WarpJammer> jammer = target;
    this->target = jammer;
}

void GuiJammerTweak::onDraw(sf::RenderTarget& window)
{
    jammer_range_slider->setValue(target->getRange());
}

GuiAsteroidTweak::GuiAsteroidTweak(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    (new GuiLabel(left_col, "", tr("Asteroid Size:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    asteroid_size_slider = new GuiSlider(left_col, "", 10, 500, 0, [this](float value) {
        target->setSize(value);
    });
    asteroid_size_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
}

void GuiAsteroidTweak::open(P<SpaceObject> target)
{
    P<Asteroid> asteroid = target;
    this->target = asteroid;
}

void GuiAsteroidTweak::onDraw(sf::RenderTarget& window)
{
    asteroid_size_slider->setValue(target->getSize());
}

void GuiShipTweakMissileWeapons::onDraw(sf::RenderTarget& window)
{
    for(int n=0; n<MW_Count; n++)
    {
        if (target->weapon_storage[n] != int(missile_current_amount_slider[n]->getValue()))
            missile_current_amount_slider[n]->setValue(float(target->weapon_storage[n]));
    }
}

void GuiShipTweakMissileWeapons::open(P<SpaceObject> target)
{
    P<SpaceShip> ship = target;
    this->target = ship;

    for(int n = 0; n < MW_Count; n++)
        missile_storage_amount_slider[n]->setValue(float(ship->weapon_storage_max[n]));
}

GuiShipTweakMissileTubes::GuiShipTweakMissileTubes(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    // Left column
    (new GuiLabel(left_col, "", tr("Tube count:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    missile_tube_amount_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->weapon_tube_count = index;
    });
    for(int n=0; n<max_weapon_tubes; n++)
        missile_tube_amount_selector->addEntry(string(n), "");
    missile_tube_amount_selector->setSize(GuiElement::GuiSizeMax, 40);

    // Right column
    tube_index = 0;
    index_selector = new GuiSelector(right_col, "", [this](int index, string value)
    {
        if (index >= target->weapon_tube_count)
        {
            if (index == max_weapon_tubes - 1)
                index = std::max(0, target->weapon_tube_count - 1);
            else
                index = 0;
            index_selector->setSelectionIndex(index);
        }
        tube_index = index;
    });
    index_selector->setSize(GuiElement::GuiSizeMax, 40);
    for(int n=0; n<max_weapon_tubes; n++)
        index_selector->addEntry(tr("Tube: {id_tube}").format({{"id_tube", string(n + 1)}}), "");
    index_selector->setSelectionIndex(0);

    (new GuiLabel(right_col, "", tr("tube", "Direction:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    direction_slider = new GuiSlider(right_col, "", -180.0, 180, 0.0, [this](float value) {
        target->weapon_tube[tube_index].setDirection(roundf(value));
    });
    direction_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", tr("tube", "Load time:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    load_time_slider = new GuiSlider(right_col, "", 0.0, 60.0, 0.0, [this](float value) {
        target->weapon_tube[tube_index].setLoadTimeConfig(roundf(value * 10) / 10);
    });
    load_time_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", tr("tube", "Size:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    size_selector=new GuiSelector(right_col, "", [this](int index, string value)
    {
        target->weapon_tube[tube_index].setSize(EMissileSizes(index));
    });
    size_selector->addEntry(tr("tube", "Small"),MS_Small);
    size_selector->addEntry(tr("tube", "Medium"),MS_Medium);
    size_selector->addEntry(tr("tube", "large"),MS_Large);
    size_selector->setSelectionIndex(MS_Medium);
    size_selector->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", tr("tube", "Allowed use:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    for(int n=0; n<MW_Count; n++)
    {
        allowed_use[n] = new GuiToggleButton(right_col, "", getLocaleMissileWeaponName(EMissileWeapons(n)), [this, n](bool value) {
            if (value)
                target->weapon_tube[tube_index].allowLoadOf(EMissileWeapons(n));
            else
                target->weapon_tube[tube_index].disallowLoadOf(EMissileWeapons(n));
        });
        allowed_use[n]->setSize(GuiElement::GuiSizeMax, 40);
    }
}

void GuiShipTweakMissileTubes::onDraw(sf::RenderTarget& window)
{
    direction_slider->setValue(sf::angleDifference(0.0f, target->weapon_tube[tube_index].getDirection()));
    load_time_slider->setValue(target->weapon_tube[tube_index].getLoadTimeConfig());
    for(int n=0; n<MW_Count; n++)
    {
        allowed_use[n]->setValue(target->weapon_tube[tube_index].canLoad(EMissileWeapons(n)));
    }
    size_selector->setSelectionIndex(target->weapon_tube[tube_index].getSize());
}

void GuiShipTweakMissileTubes::open(P<SpaceObject> target)
{
    P<SpaceShip> ship = target;
    this->target = ship;

    missile_tube_amount_selector->setSelectionIndex(ship->weapon_tube_count);
}

GuiShipTweakShields::GuiShipTweakShields(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    for(int n=0; n<max_shield_count; n++)
    {
        (new GuiLabel(left_col, "", tr("Shield {id_shield} max:").format({{"id_shield", string(n + 1)}}), 20))->setSize(GuiElement::GuiSizeMax, 30);
        shield_max_slider[n] = new GuiSlider(left_col, "", 0.0, 500, 0.0, [this, n](float value) {
            target->shield_max[n] = round(value);
            target->shield_level[n] = std::min(target->shield_level[n], target->shield_max[n]);
        });
        shield_max_slider[n]->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
    }

    for(int n=0; n<max_shield_count; n++)
    {
        (new GuiLabel(right_col, "", tr("Shield {id_shield}:").format({{"id_shield", string(n + 1)}}), 20))->setSize(GuiElement::GuiSizeMax, 30);
        shield_slider[n] = new GuiSlider(right_col, "", 0.0, 500, 0.0, [this, n](float value) {
            target->shield_level[n] = std::min(roundf(value), target->shield_max[n]);
        });
        shield_slider[n]->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
    }
}

void GuiShipTweakShields::onDraw(sf::RenderTarget& window)
{
    for(int n=0; n<max_shield_count; n++)
    {
        shield_slider[n]->setValue(target->shield_level[n]);
        shield_max_slider[n]->setValue(target->shield_max[n]);
    }
}

void GuiShipTweakShields::open(P<SpaceObject> target)
{
    P<ShipTemplateBasedObject> ship = target;
    this->target = ship;

    for(int n = 0; n < max_shield_count; n++)
    {
        shield_max_slider[n]->clearSnapValues()->addSnapValue(ship->ship_template->shield_level[n], 5.0f);
    }
}

GuiShipTweakBeamweapons::GuiShipTweakBeamweapons(GuiContainer* owner)
: GuiTweakPage(owner)
{
    beam_index = 0;

    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);
    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    GuiSelector* index_selector = new GuiSelector(left_col, "", [this](int index, string value)
    {
        beam_index = index;
    });
    index_selector->setSize(GuiElement::GuiSizeMax, 40);
    for(int n=0; n<max_beam_weapons; n++)
        index_selector->addEntry(tr("Beam: {id_beam}").format({{"id_beam", string(n + 1)}}), "");
    index_selector->setSelectionIndex(0);

    (new GuiLabel(right_col, "", tr("beam", "Arc:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    arc_slider = new GuiSlider(right_col, "", 0.0, 360.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setArc(roundf(value));
    });
    arc_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(right_col, "", tr("beam", "Direction:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    direction_slider = new GuiSlider(right_col, "", -180.0, 180.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setDirection(roundf(value));
    });
    direction_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(right_col, "", tr("beam", "Turret arc:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    turret_arc_slider = new GuiSlider(right_col, "", 0.0, 360.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setTurretArc(roundf(value));
    });
    turret_arc_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(right_col, "", tr("beam", "Turret direction:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    turret_direction_slider = new GuiSlider(right_col, "", -180.0, 180.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setTurretDirection(roundf(value));
    });
    turret_direction_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(right_col, "", tr("beam", "Turret rotation rate:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    // 25 is an arbitrary limit to add granularity; values greater than 25
    // result in practicaly instantaneous turret rotation anyway.
    turret_rotation_rate_slider = new GuiSlider(right_col, "", 0.0, 250.0, 0.0, [this](float value) {
        // Divide a large value for granularity.
        if (value > 0)
            target->beam_weapons[beam_index].setTurretRotationRate(value / 10.0);
        else
            target->beam_weapons[beam_index].setTurretRotationRate(0.0);
    });
    turret_rotation_rate_slider->setSize(GuiElement::GuiSizeMax, 30);
    // Override overlay label.
    turret_rotation_rate_overlay_label = new GuiLabel(turret_rotation_rate_slider, "", "", 30);
    turret_rotation_rate_overlay_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(right_col, "", tr("beam", "Range:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    range_slider = new GuiSlider(right_col, "", 0.0, 5000.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setRange(roundf(value / 100) * 100);
    });
    range_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(right_col, "", tr("beam", "Cycle time:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    cycle_time_slider = new GuiSlider(right_col, "", 0.1, 20.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setCycleTime(value);
    });
    cycle_time_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(right_col, "", tr("beam", "Damage:"), 20))->setSize(GuiElement::GuiSizeMax, 30);
    damage_slider = new GuiSlider(right_col, "", 0.1, 50.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setDamage(value);
    });
    damage_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
}

void GuiShipTweakBeamweapons::onDraw(sf::RenderTarget& window)
{
    target->drawOnRadar(window, sf::Vector2f(rect.left - 150.0f + rect.width / 2.0f, rect.top + rect.height * 0.66), 300.0f / 5000.0f, 0, false);

    arc_slider->setValue(target->beam_weapons[beam_index].getArc());
    direction_slider->setValue(sf::angleDifference(0.0f, target->beam_weapons[beam_index].getDirection()));
    range_slider->setValue(target->beam_weapons[beam_index].getRange());
    turret_arc_slider->setValue(target->beam_weapons[beam_index].getTurretArc());
    turret_direction_slider->setValue(sf::angleDifference(0.0f, target->beam_weapons[beam_index].getTurretDirection()));
    turret_rotation_rate_slider->setValue(target->beam_weapons[beam_index].getTurretRotationRate() * 10.0f);
    turret_rotation_rate_overlay_label->setText(string(target->beam_weapons[beam_index].getTurretRotationRate()));
    cycle_time_slider->setValue(target->beam_weapons[beam_index].getCycleTime());
    damage_slider->setValue(target->beam_weapons[beam_index].getDamage());
}

void GuiShipTweakBeamweapons::open(P<SpaceObject> target)
{
    P<SpaceShip> ship = target;
    this->target = ship;
}

GuiShipTweakSystems::GuiShipTweakSystems(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(200, GuiElement::GuiSizeMax);
    GuiAutoLayout* center_col = new GuiAutoLayout(this, "CENTER_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    center_col->setPosition(10, 25, ATopCenter)->setSize(200, GuiElement::GuiSizeMax);
    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(200, GuiElement::GuiSizeMax);

    for(int n=0; n<SYS_COUNT; n++)
    {
        ESystem system = ESystem(n);
        (new GuiLabel(left_col, "", tr("{system} health").format({{"system", getLocaleSystemName(system)}}), 20))->setSize(GuiElement::GuiSizeMax, 30);
        system_damage[n] = new GuiSlider(left_col, "", -1.0, 1.0, 0.0, [this, n](float value) {
            target->systems[n].health = std::min(value,target->systems[n].health_max);
        });
        system_damage[n]->setSize(GuiElement::GuiSizeMax, 30);
        system_damage[n]->addSnapValue(-1.0, 0.01);
        system_damage[n]->addSnapValue( 0.0, 0.01);
        system_damage[n]->addSnapValue( 1.0, 0.01);

        (new GuiLabel(center_col, "", tr("{system} health max").format({{"system", getLocaleSystemName(system)}}), 20))->setSize(GuiElement::GuiSizeMax, 30);
        system_health_max[n] = new GuiSlider(center_col, "", -1.0, 1.0, 1.0, [this, n](float value) {
            target->systems[n].health_max = value;
            target->systems[n].health = std::min(value,target->systems[n].health);
        });
        system_health_max[n]->setSize(GuiElement::GuiSizeMax, 30);
        system_health_max[n]->addSnapValue(-1.0, 0.01);
        system_health_max[n]->addSnapValue( 0.0, 0.01);
        system_health_max[n]->addSnapValue( 1.0, 0.01);

        (new GuiLabel(right_col, "", tr("{system} heat").format({{"system", getLocaleSystemName(system)}}), 20))->setSize(GuiElement::GuiSizeMax, 30);
        system_heat[n] = new GuiSlider(right_col, "", 0.0, 1.0, 0.0, [this, n](float value) {
            target->systems[n].heat_level = value;
        });
        system_heat[n]->setSize(GuiElement::GuiSizeMax, 30);
        system_heat[n]->addSnapValue( 0.0, 0.01);
        system_heat[n]->addSnapValue( 1.0, 0.01);
    }
}

void GuiShipTweakSystems::onDraw(sf::RenderTarget& window)
{
    for(int n=0; n<SYS_COUNT; n++)
    {
        system_damage[n]->setValue(target->systems[n].health);
        system_health_max[n]->setValue(target->systems[n].health_max);
        system_heat[n]->setValue(target->systems[n].heat_level);
    }
}

void GuiShipTweakSystems::open(P<SpaceObject> target)
{
    P<SpaceShip> ship = target;
    this->target = ship;
}

GuiShipTweakPlayer::GuiShipTweakPlayer(GuiContainer* owner)
: GuiTweakPage(owner)
{
    // TODO: Add more player ship tweaks here.
    // -   Ship-to-ship player transfer
    // -   Reputation

    // Add two columns.
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    // Left column
    // Edit control code.
    (new GuiLabel(left_col, "", tr("Control code:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    control_code = new GuiTextEntry(left_col, "", "");
    control_code->setSize(GuiElement::GuiSizeMax, 50);
    control_code->callback([this](string text) {
        target->control_code = text.upper();
    });

    // Edit reputation.
    (new GuiLabel(left_col, "", tr("Reputation:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    reputation_point_slider = new GuiSlider(left_col, "", 0.0, 9999.0, 0.0, [this](float value) {
        target->setReputationPoints(value);
    });
    reputation_point_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    // Edit energy level.
    (new GuiLabel(left_col, "", tr("Max energy:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    max_energy_level_slider = new GuiSlider(left_col, "", 0.0, 2000, 0.0, [this](float value) {
        target->max_energy_level = value;
        target->energy_level = std::min(target->energy_level, target->max_energy_level);
    });
    max_energy_level_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Current energy:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    energy_level_slider = new GuiSlider(left_col, "", 0.0, 2000, 0.0, [this](float value) {
        target->energy_level = std::min(value, target->max_energy_level);
    });
    energy_level_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    // Display Boost/Strafe speed sliders
    (new GuiLabel(left_col, "", tr("Boost Speed:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    combat_maneuver_boost_speed_slider = new GuiSlider(left_col, "", 0.0, 1000, 0.0, [this](float value) {
        target->combat_maneuver_boost_speed = value;
    });
    combat_maneuver_boost_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Strafe Speed:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    combat_maneuver_strafe_speed_slider = new GuiSlider(left_col, "", 0.0, 1000, 0.0, [this](float value) {
        target->combat_maneuver_strafe_speed = value;
    });
    combat_maneuver_strafe_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    // Right column
    // Count and list ship positions and whether they're occupied.
    position_count = new GuiLabel(right_col, "", tr("Positions occupied: "), 30);
    position_count->setSize(GuiElement::GuiSizeMax, 50);

    for(int n = 0; n < max_crew_positions; n++)
    {
        string position_name = getCrewPositionName(ECrewPosition(n));

        position[n] = new GuiKeyValueDisplay(right_col, "CREW_POSITION_" + position_name, 0.5, position_name, "-");
        position[n]->setSize(GuiElement::GuiSizeMax, 30);
    }
}

void GuiShipTweakPlayer::onDraw(sf::RenderTarget& window)
{
    // Update position list.
    int position_counter = 0;

    // Update the status of each crew position.
    for(int n = 0; n < max_crew_positions; n++)
    {
        string position_name = getCrewPositionName(ECrewPosition(n));
        string position_state = "-";

        if (target->hasPlayerAtPosition(ECrewPosition(n)))
        {
            position_state = tr("position", "Occupied");
            position_counter += 1;
        }

        position[n]->setValue(position_state);
    }

    // Update the total occupied position count.
    position_count->setText(tr("Positions occupied: ") + string(position_counter));

    // Update the ship's energy level.
    energy_level_slider->setValue(target->energy_level);
    max_energy_level_slider->setValue(target->max_energy_level);

    // Update reputation points.
    reputation_point_slider->setValue(target->getReputationPoints());
}

void GuiShipTweakPlayer::open(P<SpaceObject> target)
{
    P<PlayerSpaceship> player = target;
    this->target = player;

    if (player)
    {
        // Read ship's control code.
        control_code->setText(player->control_code);

        // Set and snap boost speed slider to current value
        combat_maneuver_boost_speed_slider->setValue(player->combat_maneuver_boost_speed);
        combat_maneuver_boost_speed_slider->clearSnapValues()->addSnapValue(player->combat_maneuver_boost_speed, 20.0f);

        // Set and snap strafe speed slider to current value
        combat_maneuver_strafe_speed_slider->setValue(player->combat_maneuver_strafe_speed);
        combat_maneuver_strafe_speed_slider->clearSnapValues()->addSnapValue(player->combat_maneuver_strafe_speed, 20.0f);
    }
}

GuiShipTweakPlayer2::GuiShipTweakPlayer2(GuiContainer* owner)
: GuiTweakPage(owner)
{
    // Add two columns.
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    // Left column
    (new GuiLabel(left_col, "", tr("Coolant:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    coolant_slider = new GuiSlider(left_col, "", 0.0, 50.0, 0.0, [this](float value) {
        target->setMaxCoolant(value);
    });
    coolant_slider->addSnapValue(10,1)->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Short range radar:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    short_range_radar_slider = new GuiSlider(left_col, "", 100.0, 20000.0, 0.0, [this](float value) {
        target->setShortRangeRadarRange(value);
    });
    short_range_radar_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Long range radar:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    long_range_radar_slider = new GuiSlider(left_col, "", 100.0, 100000.0, 0.0, [this](float value) {
        target->setLongRangeRadarRange(value);
    });
    long_range_radar_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Max Scan Probes:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    max_scan_probes_slider = new GuiSlider(left_col, "", 0, 20, 0.0, [this](float value) {
        target->setMaxScanProbeCount(value);
    });
    max_scan_probes_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(left_col, "", tr("Scan Probes:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    scan_probes_slider = new GuiSlider(left_col, "", 0, 20, 0.0, [this](float value) {
        target->setScanProbeCount(value);
    });
    scan_probes_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    // Right column
    // Can scan bool
    can_scan = new GuiToggleButton(right_col, "", tr("button", "Can scan"), [this](bool value) {
        target->setCanScan(value);
    });
    can_scan->setSize(GuiElement::GuiSizeMax, 40);

    // Can hack bool
    can_hack = new GuiToggleButton(right_col, "", tr("button", "Can hack"), [this](bool value) {
        target->setCanHack(value);
    });
    can_hack->setSize(GuiElement::GuiSizeMax, 40);

    // Can dock bool
    can_dock = new GuiToggleButton(right_col, "", tr("button", "Can dock"), [this](bool value) {
        target->setCanDock(value);
    });
    can_dock->setSize(GuiElement::GuiSizeMax, 40);

    // Can combat maneuver bool
    can_combat_maneuver = new GuiToggleButton(right_col, "", tr("button", "Can combat maneuver"), [this](bool value) {
        target->setCanCombatManeuver(value);
    });
    can_combat_maneuver->setSize(GuiElement::GuiSizeMax, 40);

    // Can self destruct bool
    can_self_destruct = new GuiToggleButton(right_col, "", tr("button", "Can self destruct"), [this](bool value) {
        target->setCanSelfDestruct(value);
    });
    can_self_destruct->setSize(GuiElement::GuiSizeMax, 40);

    // Can launch probe bool
    can_launch_probe = new GuiToggleButton(right_col, "", tr("button", "Can launch probes"), [this](bool value) {
        target->setCanLaunchProbe(value);
    });
    can_launch_probe->setSize(GuiElement::GuiSizeMax, 40);

    auto_coolant_enabled = new GuiToggleButton(right_col, "", tr("button", "Auto coolant"), [this](bool value) {
        target->setAutoCoolant(value);
    });
    auto_coolant_enabled->setSize(GuiElement::GuiSizeMax, 40);

    auto_repair_enabled = new GuiToggleButton(right_col, "", tr("button", "Auto repair"), [this](bool value) {
        target->commandSetAutoRepair(value);
    });
    auto_repair_enabled->setSize(GuiElement::GuiSizeMax, 40);
}

void GuiShipTweakPlayer2::onDraw(sf::RenderTarget& window)
{
    coolant_slider->setValue(target->max_coolant);
    short_range_radar_slider->setValue(target->getShortRangeRadarRange());
    long_range_radar_slider->setValue(target->getLongRangeRadarRange());
    max_scan_probes_slider->setValue(target->getMaxScanProbeCount());
    scan_probes_slider->setValue(target->getScanProbeCount());
    can_scan->setValue(target->getCanScan());
    can_hack->setValue(target->getCanHack());
    can_dock->setValue(target->getCanDock());
    can_combat_maneuver->setValue(target->getCanCombatManeuver());
    can_self_destruct->setValue(target->getCanSelfDestruct());
    can_launch_probe->setValue(target->getCanLaunchProbe());
    auto_coolant_enabled->setValue(target->auto_coolant_enabled);
    auto_repair_enabled->setValue(target->auto_repair_enabled);
}

void GuiShipTweakPlayer2::open(P<SpaceObject> target)
{
    this->target = target;
}

GuiObjectTweakBase::GuiObjectTweakBase(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(50, 25, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-25, 25, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    // Left column
    // Edit object's callsign.
    (new GuiLabel(left_col, "", tr("Callsign:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    callsign = new GuiTextEntry(left_col, "", "");
    callsign->setSize(GuiElement::GuiSizeMax, 50);
    callsign->callback([this](string text) {
        target->callsign = text;
    });

    // Edit object's description.
    // TODO: Fix long strings in GuiTextEntry, or make a new GUI element for
    // editing long strings.
    (new GuiLabel(left_col, "", tr("Unscanned description:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    unscanned_description = new GuiTextEntry(left_col, "", "");
    unscanned_description->setSize(GuiElement::GuiSizeMax, 50);
    unscanned_description->callback([this](string text) {
        target->setDescriptionForScanState(SS_NotScanned,text);
    });

    (new GuiLabel(left_col, "", tr("Friend or Foe Description:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    friend_or_foe_description = new GuiTextEntry(left_col, "", "");
    friend_or_foe_description->setSize(GuiElement::GuiSizeMax, 50);
    friend_or_foe_description->callback([this](string text) {
        target->setDescriptionForScanState(SS_FriendOrFoeIdentified,text);
    });

    (new GuiLabel(left_col, "", tr("Simple Scan Description:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    simple_scan_description = new GuiTextEntry(left_col, "", "");
    simple_scan_description->setSize(GuiElement::GuiSizeMax, 50);
    simple_scan_description->callback([this](string text) {
        target->setDescriptionForScanState(SS_SimpleScan,text);
    });

    (new GuiLabel(left_col, "", tr("Full Scan Description:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    full_scan_description = new GuiTextEntry(left_col, "", "");
    full_scan_description->setSize(GuiElement::GuiSizeMax, 50);
    full_scan_description->callback([this](string text) {
        target->setDescriptionForScanState(SS_FullScan,text);
    });

    // Right column

    // Set object's heading.
    (new GuiLabel(right_col, "", tr("Heading:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    heading_slider = new GuiSlider(right_col, "", 0.0, 359.9, 0.0, [this](float value) {
        target->setHeading(value);
    });
    heading_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", tr("Scanning Complexity:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    scanning_complexity_slider = new GuiSlider(right_col, "", 0, 4, 0, [this](float value) {
        target->setScanningParameters(value,target->scanningChannelDepth(target));
    });
    scanning_complexity_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", tr("Scanning Depth:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    scanning_depth_slider = new GuiSlider(right_col, "", 1, 5, 0, [this](float value) {
        target->setScanningParameters(target->scanningComplexity(target),value);
    });
    scanning_depth_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
}

void GuiObjectTweakBase::onDraw(sf::RenderTarget& window)
{
    heading_slider->setValue(target->getHeading());

    callsign->setText(target->callsign);
    // TODO: Fix long strings in GuiTextEntry, or make a new GUI element for
    // editing long strings.
    unscanned_description->setText(target->getDescription(SS_NotScanned));
    friend_or_foe_description->setText(target->getDescription(SS_FriendOrFoeIdentified));
    simple_scan_description->setText(target->getDescription(SS_SimpleScan));
    full_scan_description->setText(target->getDescription(SS_FullScan));

    // we probably dont need to set these each onDraw
    // but doing it forces the slider to round to a integer
    scanning_complexity_slider->setValue(target->scanningComplexity(target));
    scanning_depth_slider->setValue(target->scanningChannelDepth(target));
}

void GuiObjectTweakBase::open(P<SpaceObject> target)
{
    this->target = target;
}
