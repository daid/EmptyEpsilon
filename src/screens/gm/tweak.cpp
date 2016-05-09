#include "tweak.h"
#include "spaceObjects/spaceship.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_label.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"

GuiShipTweak::GuiShipTweak(GuiContainer* owner)
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
    list->setPosition(5, 25, ATopLeft);
    
    pages.push_back(new GuiShipTweakBase(this));
    list->addEntry("Base", "");
    pages.push_back(new GuiShipTweakShields(this));
    list->addEntry("Shields", "");
    pages.push_back(new GuiShipTweakMissileWeapons(this));
    list->addEntry("Missiles", "");
    pages.push_back(new GuiShipTweakBeamweapons(this));
    list->addEntry("Beams", "");
    pages.push_back(new GuiShipTweakSystems(this));
    list->addEntry("Systems", "");

    for(GuiTweakPage* page : pages)
    {
        page->setSize(700, 600)->setPosition(0, 0, ABottomRight)->hide();
    }
    pages[0]->show();
    list->setSelectionIndex(0);

    (new GuiButton(this, "CLOSE_BUTTON", "Close", [this]() {
        hide();
    }))->setTextSize(20)->setPosition(-10, 0, ATopRight)->setSize(70, 30);
}

void GuiShipTweak::open(P<SpaceShip> target)
{
    this->target = target;
    for(GuiTweakPage* page : pages)
        page->open(target);
    show();
}

void GuiShipTweak::onDraw(sf::RenderTarget& window)
{
    GuiPanel::onDraw(window);
    
    if (!target)
        hide();
}

GuiShipTweakBase::GuiShipTweakBase(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(20, 20, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);
    
    (new GuiLabel(left_col, "", "Type name:", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    
    type_name = new GuiTextEntry(left_col, "", "");
    type_name->setSize(GuiElement::GuiSizeMax, 50);
    type_name->callback([this](string text) {
        target->setTypeName(text);
    });

    (new GuiLabel(left_col, "", "Callsign:", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    
    callsign = new GuiTextEntry(left_col, "", "");
    callsign->setSize(GuiElement::GuiSizeMax, 50);
    callsign->callback([this](string text) {
        target->callsign = text;
    });
    
    warp_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->setWarpDrive(index != 0);
    });
    warp_selector->setOptions({"WarpDrive: No", "WarpDrive: Yes"})->setSize(GuiElement::GuiSizeMax, 50);
    jump_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->setJumpDrive(index != 0);
    });
    jump_selector->setOptions({"JumpDrive: No", "JumpDrive: Yes"})->setSize(GuiElement::GuiSizeMax, 50);
    
    (new GuiLabel(left_col, "", "Impulse speed:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    impulse_speed_slider = new GuiSlider(left_col, "", 0.0, 250, 0.0, [this](float value) {
        target->impulse_max_speed = value;
    });
    impulse_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 50);
    
    (new GuiLabel(left_col, "", "Turn speed:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    turn_speed_slider = new GuiSlider(left_col, "", 0.0, 25, 0.0, [this](float value) {
        target->turn_speed = value;
    });
    turn_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 50);
    
    (new GuiLabel(right_col, "", "Hull max:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    hull_max_slider = new GuiSlider(right_col, "", 0.0, 500, 0.0, [this](float value) {
        target->hull_max = round(value);
        target->hull_strength = std::min(target->hull_strength, target->hull_max);
    });
    hull_max_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(right_col, "", "Hull current:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    hull_slider = new GuiSlider(right_col, "", 0.0, 500, 0.0, [this](float value) {
        target->hull_strength = std::min(roundf(value), target->hull_max);
    });
    hull_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 50);
}

void GuiShipTweakBase::onDraw(sf::RenderTarget& window)
{
    hull_slider->setValue(target->hull_strength);
}

void GuiShipTweakBase::open(P<SpaceShip> target)
{
    this->target = target;
    
    type_name->setText(target->getTypeName());
    callsign->setText(target->callsign);
    warp_selector->setSelectionIndex(target->has_warp_drive ? 1 : 0);
    jump_selector->setSelectionIndex(target->hasJumpDrive() ? 1 : 0);
    impulse_speed_slider->setValue(target->impulse_max_speed);
    impulse_speed_slider->clearSnapValues()->addSnapValue(target->ship_template->impulse_speed, 5.0f);
    turn_speed_slider->setValue(target->turn_speed);
    turn_speed_slider->clearSnapValues()->addSnapValue(target->ship_template->turn_speed, 1.0f);
    hull_max_slider->setValue(target->hull_max);
    hull_max_slider->clearSnapValues()->addSnapValue(target->ship_template->hull, 5.0f);
}

GuiShipTweakMissileWeapons::GuiShipTweakMissileWeapons(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(20, 20, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    (new GuiLabel(left_col, "", "Storage space:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    for(int n=0; n<MW_Count; n++)
    {
        missile_storage_amount_selector[n] = new GuiSelector(left_col, "", [this, n](int index, string value) {
            target->weapon_storage_max[n] = index;
            target->weapon_storage[n] = std::min(target->weapon_storage[n], target->weapon_storage_max[n]);
        });
        for(int m=0; m<50; m++)
            missile_storage_amount_selector[n]->addEntry(getMissileWeaponName(EMissileWeapons(n)) + ": " + string(m), "");
        missile_storage_amount_selector[n]->setSize(GuiElement::GuiSizeMax, 50);
    }

    (new GuiLabel(left_col, "", "Tube count:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    missile_tube_amount_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->weapon_tube_count = index;
    });
    for(int n=0; n<max_weapon_tubes; n++)
        missile_tube_amount_selector->addEntry(string(n), "");
    missile_tube_amount_selector->setSize(GuiElement::GuiSizeMax, 50);

    (new GuiLabel(right_col, "", "Stored amount:", 30))->setSize(GuiElement::GuiSizeMax, 50);
    for(int n=0; n<MW_Count; n++)
    {
        missile_current_amount_selector[n] = new GuiSelector(right_col, "", [this, n](int index, string value) {
            target->weapon_storage[n] = std::min(index, int(target->weapon_storage_max[n]));
        });
        for(int m=0; m<50; m++)
            missile_current_amount_selector[n]->addEntry(getMissileWeaponName(EMissileWeapons(n)) + ": " + string(m), "");
        missile_current_amount_selector[n]->setSize(GuiElement::GuiSizeMax, 50);
    }
}

void GuiShipTweakMissileWeapons::onDraw(sf::RenderTarget& window)
{
    for(int n=0; n<MW_Count; n++)
    {
        if (target->weapon_storage[n] != missile_current_amount_selector[n]->getSelectionIndex())
            missile_current_amount_selector[n]->setSelectionIndex(target->weapon_storage[n]);
    }
}

void GuiShipTweakMissileWeapons::open(P<SpaceShip> target)
{
    missile_tube_amount_selector->setSelectionIndex(target->weapon_tube_count);
    for(int n=0; n<MW_Count; n++)
        missile_storage_amount_selector[n]->setSelectionIndex(target->weapon_storage_max[n]);

    this->target = target;
}

GuiShipTweakShields::GuiShipTweakShields(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(20, 20, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);

    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);
    
    for(int n=0; n<max_shield_count; n++)
    {
        (new GuiLabel(left_col, "", "Shield " + string(n + 1) + " max:", 20))->setSize(GuiElement::GuiSizeMax, 30);
        shield_max_slider[n] = new GuiSlider(left_col, "", 0.0, 500, 0.0, [this, n](float value) {
            target->shield_max[n] = round(value);
            target->shield_level[n] = std::min(target->shield_level[n], target->shield_max[n]);
        });
        shield_max_slider[n]->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
    }

    for(int n=0; n<max_shield_count; n++)
    {
        (new GuiLabel(right_col, "", "Shield " + string(n + 1) + ":", 20))->setSize(GuiElement::GuiSizeMax, 30);
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
    }
}

void GuiShipTweakShields::open(P<SpaceShip> target)
{
    this->target = target;

    for(int n=0; n<max_shield_count; n++)
    {
        shield_max_slider[n]->setValue(target->shield_max[n]);
        shield_max_slider[n]->clearSnapValues()->addSnapValue(target->ship_template->shield_level[n], 5.0f);
    }
}

GuiShipTweakBeamweapons::GuiShipTweakBeamweapons(GuiContainer* owner)
: GuiTweakPage(owner)
{
    beam_index = 0;

    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(20, 20, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);
    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);
    
    GuiSelector* index_selector = new GuiSelector(left_col, "", [this](int index, string value)
    {
        beam_index = index;
    });
    index_selector->setSize(GuiElement::GuiSizeMax, 40);
    for(int n=0; n<max_beam_weapons; n++)
        index_selector->addEntry("Beam: " + string(n + 1), "");
    index_selector->setSelectionIndex(0);

    (new GuiLabel(right_col, "", "Arc:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    arc_slider = new GuiSlider(right_col, "", 0.0, 360, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setArc(roundf(value));
    });
    arc_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", "Direction:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    direction_slider = new GuiSlider(right_col, "", -180.0, 180, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setDirection(roundf(value));
    });
    direction_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", "Range:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    range_slider = new GuiSlider(right_col, "", 0.0, 5000.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setRange(roundf(value / 100) * 100);
    });
    range_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", "Cycle time:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    cycle_time_slider = new GuiSlider(right_col, "", 0.1, 20.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setCycleTime(value);
    });
    cycle_time_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);

    (new GuiLabel(right_col, "", "Damage:", 20))->setSize(GuiElement::GuiSizeMax, 30);
    damage_slider = new GuiSlider(right_col, "", 0.1, 50.0, 0.0, [this](float value) {
        target->beam_weapons[beam_index].setDamage(value);
    });
    damage_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 40);
}

void GuiShipTweakBeamweapons::onDraw(sf::RenderTarget& window)
{
    target->drawOnRadar(window, sf::Vector2f(rect.left + rect.width / 2.0f, rect.top + rect.height * 0.8), 300.0f / 5000.0f, false);

    arc_slider->setValue(target->beam_weapons[beam_index].getArc());
    direction_slider->setValue(sf::angleDifference(0.0f, target->beam_weapons[beam_index].getDirection()));
    range_slider->setValue(target->beam_weapons[beam_index].getRange());
    cycle_time_slider->setValue(target->beam_weapons[beam_index].getCycleTime());
    damage_slider->setValue(target->beam_weapons[beam_index].getDamage());
}

void GuiShipTweakBeamweapons::open(P<SpaceShip> target)
{
    this->target = target;
}

GuiShipTweakSystems::GuiShipTweakSystems(GuiContainer* owner)
: GuiTweakPage(owner)
{
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(20, 20, ATopLeft)->setSize(300, GuiElement::GuiSizeMax);
    GuiAutoLayout* right_col = new GuiAutoLayout(this, "RIGHT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_col->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);
    
    for(int n=0; n<SYS_COUNT; n++)
    {
        ESystem system = ESystem(n);
        (new GuiLabel(left_col, "", getSystemName(system) + " health", 20))->setSize(GuiElement::GuiSizeMax, 30);
        system_damage[n] = new GuiSlider(left_col, "", -1.0, 1.0, 0.0, [this, n](float value) {
            target->systems[n].health = value;
        });
        system_damage[n]->setSize(GuiElement::GuiSizeMax, 30);
        system_damage[n]->addSnapValue(-1.0, 0.01);
        system_damage[n]->addSnapValue( 0.0, 0.01);
        system_damage[n]->addSnapValue( 1.0, 0.01);

        (new GuiLabel(right_col, "", getSystemName(system) + " heat", 20))->setSize(GuiElement::GuiSizeMax, 30);
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
        system_heat[n]->setValue(target->systems[n].heat_level);
    }
}

void GuiShipTweakSystems::open(P<SpaceShip> target)
{
    this->target = target;
}
