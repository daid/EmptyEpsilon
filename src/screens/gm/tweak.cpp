#include <i18n.h>
#include "tweak.h"
#include "playerInfo.h"
#include "components/collision.h"
#include "components/name.h"
#include "components/ai.h"
#include "components/avoidobject.h"
#include "components/beamweapon.h"
#include "components/comms.h"
#include "components/coolant.h"
#include "components/docking.h"
#include "components/gravity.h"
#include "components/hacking.h"
#include "components/hull.h"
#include "components/impulse.h"
#include "components/jumpdrive.h"
#include "components/lifetime.h"
#include "components/maneuveringthrusters.h"
#include "components/missile.h"
#include "components/missiletubes.h"
#include "components/name.h"
#include "components/orbit.h"
#include "components/pickup.h"
#include "components/player.h"
#include "components/probe.h"
#include "components/radar.h"
#include "components/radarblock.h"
#include "components/reactor.h"
#include "components/rendering.h"
#include "components/scanning.h"
#include "components/selfdestruct.h"
#include "components/shields.h"
#include "components/spin.h"
#include "components/warpdrive.h"


#include "gui/gui2_listbox.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_togglebutton.h"


class GuiTextTweak : public GuiTextEntry {
public:
    GuiTextTweak(GuiContainer* owner) : GuiTextEntry(owner, "", "") {
        setSize(GuiElement::GuiSizeMax, 30);
        setTextSize(20);
    }
    virtual void onDraw(sp::RenderTarget& target) override {
        if (!focus) setText(update_func());
        GuiTextEntry::onDraw(target);
    }
    std::function<string()> update_func;
};
class GuiToggleTweak : public GuiToggleButton {
public:
    GuiToggleTweak(GuiContainer* owner, const string& label, GuiToggleButton::func_t callback) : GuiToggleButton(owner, "", label, callback) {
        setSize(GuiElement::GuiSizeMax, 30);
        setTextSize(20);
    }
    virtual void onDraw(sp::RenderTarget& target) override {
        if (update_func) setValue(update_func());
        GuiToggleButton::onDraw(target);
    }
    std::function<bool()> update_func;
};
class GuiVectorTweak : public GuiSelector {
public:
    GuiVectorTweak(GuiContainer* owner, string id)
    : GuiSelector(owner, id, [](int index, string value) {}) {
        setSize(GuiElement::GuiSizeMax, 30);
        setTextSize(20);
    }
    virtual void onDraw(sp::RenderTarget& target) override {
        if (update_func) {
            int count = update_func();
            while(count > entryCount())
                addEntry(string(entryCount()+1), entryCount());
            while(count < entryCount())
                removeEntry(entryCount()-1);
        }
        GuiSelector::onDraw(target);
    }
    std::function<size_t()> update_func;
};


#define ADD_PAGE(LABEL, COMPONENT) \
    new_page = new GuiTweakPage(this); \
    new_page->has_component = [](sp::ecs::Entity e) { return e.hasComponent<COMPONENT>(); }; \
    new_page->add_component = [](sp::ecs::Entity e) { e.addComponent<COMPONENT>(); }; \
    new_page->remove_component = [](sp::ecs::Entity e) { e.removeComponent<COMPONENT>(); }; \
    pages.push_back(new_page); \
    list->addEntry(LABEL, "");
#define ADD_LABEL(LABEL) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
    } while(0)
#define ADD_TEXT_TWEAK(LABEL, COMPONENT, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiTextTweak(row); \
        ui->update_func = [this]() -> string { auto v = entity.getComponent<COMPONENT>(); if (v) return v->VALUE; return ""; }; \
        ui->callback([this](string text) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = text; }); \
    } while(0)
#define ADD_NUM_TEXT_TWEAK(LABEL, COMPONENT, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiTextTweak(row); \
        ui->update_func = [this]() -> string { auto v = entity.getComponent<COMPONENT>(); if (v) return string(v->VALUE, 3); return ""; }; \
        ui->callback([this](string text) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = text.toFloat(); }); \
    } while(0)
#define ADD_BOOL_TWEAK(LABEL, COMPONENT, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiToggleTweak(row, "", [this](bool value) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = value; }); \
        ui->update_func = [this]() -> bool { auto v = entity.getComponent<COMPONENT>(); if (v) return v->VALUE; return false; }; \
    } while(0)
#define ADD_VECTOR(LABEL, COMPONENT, VECTOR) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        vector_selector = new GuiVectorTweak(row, "VECTOR_SELECTOR"); \
        vector_selector->update_func = [this]() -> size_t { auto v = entity.getComponent<COMPONENT>(); if (v) return v->VECTOR.size(); return 0; }; \
        auto add = new GuiButton(row, "", "Add", [this, vector_selector](){ auto v = entity.getComponent<COMPONENT>(); if (v) { v->VECTOR.emplace_back(); vector_selector->setSelectionIndex(v->VECTOR.size()); } }); \
        add->setTextSize(20)->setSize(50, 30); \
        auto del = new GuiButton(row, "", "Del", [this](){ auto v = entity.getComponent<COMPONENT>(); if (v) v->VECTOR.pop_back(); }); \
        del->setTextSize(20)->setSize(50, 30); \
    } while(0)
#define ADD_VECTOR_NUM_TEXT_TWEAK(LABEL, COMPONENT, VECTOR, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiTextTweak(row); \
        ui->update_func = [this, vector_selector]() -> string { auto v = entity.getComponent<COMPONENT>(); \
            if (v && vector_selector->getSelectionIndex() >= 0 && vector_selector->getSelectionIndex() < int(v->VECTOR.size())) \
                return string(v->VECTOR[vector_selector->getSelectionIndex()].VALUE); \
            return ""; \
        }; \
        ui->callback([this, vector_selector](string text) { auto v = entity.getComponent<COMPONENT>(); \
            if (v && vector_selector->getSelectionIndex() >= 0 && vector_selector->getSelectionIndex() < int(v->VECTOR.size())) \
                v->VECTOR[vector_selector->getSelectionIndex()].VALUE = text.toFloat(); \
        }); \
    } while(0)
#define ADD_SHIP_SYSTEM_TWEAK(SYSTEM) \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Health:"), SYSTEM, health); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Health max:"), SYSTEM, health_max); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Heat:"), SYSTEM, heat_level); \
      ADD_BOOL_TWEAK(tr("tweak-text", "Can be hacked:"), SYSTEM, can_be_hacked); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Power factor:"), SYSTEM, power_factor); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Heat rate:"), SYSTEM, heat_add_rate_per_second); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Coolant change rate:"), SYSTEM, coolant_change_rate_per_second); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Power change rate:"), SYSTEM, power_change_rate_per_second); \
      ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Auto repair:"), SYSTEM, auto_repair_per_second);

GuiEntityTweak::GuiEntityTweak(GuiContainer* owner)
: GuiPanel(owner, "GM_TWEAK_DIALOG")
{
    setPosition(0, -100, sp::Alignment::BottomCenter);
    setSize(1000, 700);

    GuiListbox* list = new GuiListbox(this, "", [this](int index, string value)
    {
        for(GuiTweakPage* page : pages)
            page->hide();
        pages[index]->show();
    });

    list->setSize(300, GuiElement::GuiSizeMax);
    list->setPosition(25, 25, sp::Alignment::TopLeft);

    GuiTweakPage* new_page;
    GuiVectorTweak* vector_selector;

    ADD_PAGE(tr("tweak-tab", "Callsign"), CallSign);
    ADD_TEXT_TWEAK(tr("tweak-text", "Callsign:"), CallSign, callsign);

    ADD_PAGE(tr("tweak-tab", "Type name"), TypeName);
    ADD_TEXT_TWEAK(tr("tweak-text", "Type name:"), TypeName, type_name);
    ADD_TEXT_TWEAK(tr("tweak-text", "Localized:"), TypeName, localized);

    ADD_PAGE(tr("tweak-tab", "Coolant"), Coolant);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max:"), Coolant, max);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max per system:"), Coolant, max_coolant_per_system);
    ADD_BOOL_TWEAK(tr("tweak-text", "Auto levels:"), Coolant, auto_levels);

    ADD_PAGE(tr("tweak-tab", "Hull"), Hull);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Current:"), Hull, current);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max:"), Hull, max);
    ADD_BOOL_TWEAK(tr("tweak-text", "Allow destruction:"), Hull, allow_destruction);

    ADD_PAGE(tr("tweak-tab", "Impulse engine"), ImpulseEngine);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Speed forward:"), ImpulseEngine, max_speed_forward);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Speed reverse:"), ImpulseEngine, max_speed_reverse);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Acceleration forward:"), ImpulseEngine, acceleration_forward);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Acceleration reverse:"), ImpulseEngine, acceleration_reverse);
    ADD_LABEL(tr("tweak-text", "Impulse engine system"));
    ADD_SHIP_SYSTEM_TWEAK(ImpulseEngine);

    ADD_PAGE(tr("tweak-tab", "Maneuvering thrusters"), ManeuveringThrusters);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Rotational speed:"), ManeuveringThrusters, speed);
    ADD_LABEL(tr("tweak-text", "Maneuvering thrusters system"));
    ADD_SHIP_SYSTEM_TWEAK(ManeuveringThrusters);

    ADD_PAGE(tr("tweak-tab", "Combat thrusters"), CombatManeuveringThrusters);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Charge available (0 to 1):"), CombatManeuveringThrusters, charge);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Seconds to full recharge from 0:"), CombatManeuveringThrusters, charge_time);

    ADD_PAGE(tr("tweak-tab", "Beam system"), BeamWeaponSys);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Frequency:"), BeamWeaponSys, frequency);
    ADD_LABEL(tr("tweak-text", "Beam weapons system"));
    ADD_SHIP_SYSTEM_TWEAK(BeamWeaponSys);

    ADD_PAGE(tr("tweak-tab", "Beam mounts"), BeamWeaponSys);
    ADD_VECTOR(tr("tweak-vector", "Mounts"), BeamWeaponSys, mounts);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Arc:"), BeamWeaponSys, mounts, arc);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Direction:"), BeamWeaponSys, mounts, direction);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Range:"), BeamWeaponSys, mounts, range);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Cycle time:"), BeamWeaponSys, mounts, cycle_time);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Damage:"), BeamWeaponSys, mounts, damage);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Turret arc:"), BeamWeaponSys, mounts, turret_arc);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Turret direction:"), BeamWeaponSys, mounts, turret_direction);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Turret rotation rate:"), BeamWeaponSys, mounts, turret_rotation_rate);

    ADD_PAGE(tr("tweak-tab", "Missile system"), MissileTubes);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Homing missiles:"), MissileTubes, storage[MW_Homing]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Nuke missiles:"), MissileTubes, storage[MW_Nuke]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Mines:"), MissileTubes, storage[MW_Mine]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "EMP missiles:"), MissileTubes, storage[MW_EMP]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "HVLI missiles:"), MissileTubes, storage[MW_HVLI]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Homing capacity:"), MissileTubes, storage_max[MW_Homing]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Nuke capacity:"), MissileTubes, storage_max[MW_Nuke]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Mines capacity:"), MissileTubes, storage_max[MW_Mine]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "EMP capacity:"), MissileTubes, storage_max[MW_EMP]);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "HVLI capacity:"), MissileTubes, storage_max[MW_HVLI]);
    ADD_LABEL(tr("tweak-text", "Missile weapons system"));
    ADD_SHIP_SYSTEM_TWEAK(MissileTubes);

    ADD_PAGE(tr("tweak-tab", "Missile mounts"), MissileTubes);
    ADD_VECTOR(tr("tweak-vector", "Mounts"), MissileTubes, mounts);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Direction:"), MissileTubes, mounts, direction);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Load time:"), MissileTubes, mounts, load_time);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Types allowed mask:"), MissileTubes, mounts, type_allowed_mask);

    ADD_PAGE(tr("tweak-tab", "Shields"), Shields);
    // Unsure how to access the shield component's front/rear systems
    // ADD_LABEL(tr("tweak-text", "Shields systems"));
    // ADD_SHIP_SYSTEM_TWEAK(Shields, front_system);
    // ADD_SHIP_SYSTEM_TWEAK(Shields, rear_system);
    ADD_BOOL_TWEAK(tr("tweak-text", "Active:"), Shields, active);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Seconds to recalibrate:"), Shields, calibration_time);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Frequency:"), Shields, frequency);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Energy use per second:"), Shields, energy_use_per_second);
    ADD_VECTOR(tr("tweak-vector", "Shields"), Shields, entries);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Level:"), Shields, entries, level);
    ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Max:"), Shields, entries, max);
    // Timer on shield hit effect used by threat level; not a useful control
    // ADD_VECTOR_NUM_TEXT_TWEAK(tr("tweak-text", "Hit effect:"), Shields, entries, hit_effect);

    ADD_PAGE(tr("tweak-tab", "Warp drive"), WarpDrive);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max level:"), WarpDrive, max_level);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Speed per level:"), WarpDrive, speed_per_level);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Energy per second:"), WarpDrive, energy_warp_per_second);
    ADD_LABEL(tr("tweak-text", "Warp drive system"));
    ADD_SHIP_SYSTEM_TWEAK(WarpDrive);

    ADD_PAGE(tr("tweak-tab", "Jump drive"), JumpDrive);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Min distance:"), JumpDrive, min_distance);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max distance:"), JumpDrive, max_distance);
    ADD_LABEL(tr("tweak-text", "Jump drive system"));
    ADD_SHIP_SYSTEM_TWEAK(JumpDrive);

    // This fails, so there's no way to remove the AI component from a CPU ship,
    // which makes it difficult to convert a CPU ship to a player ship.
    // ADD_PAGE(tr("tweak-tab", "AI ship"), AIController);

    ADD_PAGE(tr("tweak-tab", "Player ship"), PlayerControl);
    ADD_TEXT_TWEAK(tr("tweak-text", "Control code:"), PlayerControl, control_code);

    ADD_PAGE(tr("tweak-tab", "Reactor"), Reactor);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Energy:"), Reactor, energy);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max energy:"), Reactor, max_energy);
    ADD_BOOL_TWEAK(tr("tweak-text", "Explode on overload:"), Reactor, overload_explode);
    ADD_LABEL(tr("tweak-text", "Reactor system"));
    ADD_SHIP_SYSTEM_TWEAK(Reactor);

    ADD_PAGE(tr("tweak-tab", "Radar"), LongRangeRadar);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Short-range radar range:"), LongRangeRadar, short_range);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Long-range radar range:"), LongRangeRadar, long_range);

    ADD_PAGE(tr("tweak-tab", "Scanner"), ScienceScanner);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Countdown delay:"), ScienceScanner, delay);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max delay:"), ScienceScanner, max_scanning_delay);

    ADD_PAGE(tr("tweak-tab", "Comms receiver"), CommsReceiver);
    ADD_PAGE(tr("tweak-tab", "Comms transmitter"), CommsTransmitter);

    ADD_PAGE(tr("tweak-tab", "Scan probe launcher"), ScanProbeLauncher);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Stored probes:"), ScanProbeLauncher, stock);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max probe storage:"), ScanProbeLauncher, max);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Probe restocking delay:"), ScanProbeLauncher, charge_time);

    ADD_PAGE(tr("tweak-tab", "Hacking"), HackingDevice);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Effectiveness:"), HackingDevice, effectiveness);

    ADD_PAGE(tr("tweak-tab", "Self-destruct"), SelfDestruct);
    ADD_BOOL_TWEAK(tr("tweak-text", "Active:"), SelfDestruct, active);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Countdown:"), SelfDestruct, countdown);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Blast damage:"), SelfDestruct, damage);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Blast radius:"), SelfDestruct, size);

    ADD_PAGE(tr("tweak-tab", "Radar obstruction"), RadarBlock);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Radius:"), RadarBlock, range);
    ADD_BOOL_TWEAK(tr("tweak-text", "Obstructs radar behind:"), RadarBlock, behind);

    ADD_PAGE(tr("tweak-tab", "Gravity"), Gravity);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Radius:"), Gravity, range);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Force:"), Gravity, force);
    ADD_BOOL_TWEAK(tr("tweak-text", "Black hole damage:"), Gravity, damage);

    for(GuiTweakPage* page : pages)
    {
        page->setSize(700, 700)->setPosition(0, 0, sp::Alignment::BottomRight)->hide();
    }

    pages[0]->show();
    list->setSelectionIndex(0);

    (new GuiButton(this, "CLOSE_BUTTON", tr("button", "Close"), [this]() {
        hide();
    }))->setTextSize(20)->setPosition(-10, 0, sp::Alignment::TopRight)->setSize(70, 30);
}

void GuiEntityTweak::open(sp::ecs::Entity e)
{
    entity = e;
    for(auto page : pages)
        page->open(e);
    show();
}

GuiTweakPage::GuiTweakPage(GuiContainer* owner)
: GuiElement(owner, "")
{
    add_remove_button = new GuiButton(this, "ADD_REMOVE", "", [this](){
        if (has_component(entity))
            remove_component(entity);
        else
            add_component(entity);
    });
    add_remove_button->setSize(300, 50)->setPosition(0, 15, sp::Alignment::TopCenter);

    contents = new GuiElement(this, "CONTENT");
    contents->setPosition(0, 75, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    contents->setMargins(30, 0);
}

void GuiTweakPage::open(sp::ecs::Entity e)
{
    entity = e;
}

void GuiTweakPage::onDraw(sp::RenderTarget& target)
{
    if (has_component(entity)) {
        add_remove_button->setText(tr("tweak-button", "Remove component"));
        contents->show();
    } else {
        add_remove_button->setText(tr("tweak-button", "Create component"));
        contents->hide();
    }
}
