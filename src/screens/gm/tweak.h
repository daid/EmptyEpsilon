#ifndef TWEAK_H
#define TWEAK_H

#include "gui/gui2_panel.h"
#include "missileWeaponData.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "spaceObjects/warpJammer.h"
#include "spaceObjects/asteroid.h"

class SpaceShip;
class GuiKeyValueDisplay;
class GuiLabel;
class GuiTextEntry;
class GuiSlider;
class GuiSelector;
class GuiToggleButton;

enum ETweakType
{
    TW_Object,  // TODO: Space object
    TW_Jammer,  // WarpJammer
    TW_Ship,    // Ships
    TW_Station, // TODO: Space stations
    TW_Player,  // Player ships
    TW_Asteroid // Asteroid
};

class GuiTweakPage : public GuiElement
{
public:
    GuiTweakPage(GuiContainer* owner) : GuiElement(owner, "") {}

    virtual void open(P<SpaceObject> target) = 0;
};

class GuiObjectTweak : public GuiPanel
{
public:
    GuiObjectTweak(GuiContainer* owner, ETweakType tweak_type);

    void open(P<SpaceObject> target);

    virtual void onDraw(sf::RenderTarget& window) override;
private:
    P<SpaceObject> target;
    std::vector<GuiTweakPage*> pages;
};

class GuiTweakShip : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiTextEntry* type_name;
    GuiToggleButton* warp_toggle;
    GuiToggleButton* jump_toggle;
    GuiSlider* impulse_speed_slider;
    GuiSlider* turn_speed_slider;
    GuiSlider* hull_max_slider;
    GuiSlider* hull_slider;
    GuiSlider* jump_charge_slider;
    GuiSlider* jump_min_distance_slider;
    GuiSlider* jump_max_distance_slider;
    GuiToggleButton* can_be_destroyed_toggle;
    GuiSlider* short_range_radar_slider;
    GuiSlider* long_range_radar_slider;
public:
    GuiTweakShip(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual void open(P<SpaceObject> target) override;
};

class GuiJammerTweak : public GuiTweakPage
{
private:
    P<WarpJammer> target;

    GuiSlider* jammer_range_slider;
public:
    GuiJammerTweak(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual void open(P<SpaceObject> target) override;
};

class GuiAsteroidTweak : public GuiTweakPage
{
private:
    P<Asteroid> target;

    GuiSlider* asteroid_size_slider;
public:
    GuiAsteroidTweak(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual void open(P<SpaceObject> target) override;
};

class GuiShipTweakMissileWeapons : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiSlider* missile_storage_amount_slider[MW_Count];
    GuiSlider* missile_current_amount_slider[MW_Count];
public:
    GuiShipTweakMissileWeapons(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual void open(P<SpaceObject> target) override;
};

class GuiShipTweakMissileTubes : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    int tube_index;
    GuiSelector* index_selector;
    GuiSelector* missile_tube_amount_selector;
    GuiSlider* direction_slider;
    GuiSlider* load_time_slider;
    GuiSelector* size_selector;
    GuiToggleButton* allowed_use[MW_Count];
public:
    GuiShipTweakMissileTubes(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual void open(P<SpaceObject> target) override;
};

class GuiShipTweakShields : public GuiTweakPage
{
private:
    P<ShipTemplateBasedObject> target;

    GuiSlider* shield_max_slider[max_shield_count];
    GuiSlider* shield_slider[max_shield_count];
public:
    GuiShipTweakShields(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;

    virtual void open(P<SpaceObject> target) override;
};

class GuiShipTweakBeamweapons : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    int beam_index;
    GuiSlider* arc_slider;
    GuiSlider* direction_slider;
    GuiSlider* range_slider;
    GuiSlider* turret_arc_slider;
    GuiSlider* turret_direction_slider;
    GuiSlider* turret_rotation_rate_slider;
    GuiLabel* turret_rotation_rate_overlay_label;
    GuiSlider* cycle_time_slider;
    GuiSlider* damage_slider;
public:
    GuiShipTweakBeamweapons(GuiContainer* owner);

    virtual void open(P<SpaceObject> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};

class GuiShipTweakSystems : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiSlider* system_damage[SYS_COUNT];
    GuiSlider* system_health_max[SYS_COUNT];
    GuiSlider* system_heat[SYS_COUNT];

public:
    GuiShipTweakSystems(GuiContainer* owner);

    virtual void open(P<SpaceObject> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};

class GuiShipTweakSystemPowerFactors : public GuiTweakPage
{
private:
    P<SpaceShip> target;
    GuiLabel* system_current_power_factor[SYS_COUNT];
    GuiTextEntry* system_power_factor[SYS_COUNT];

    static string powerFactorToText(float);
public:
    explicit GuiShipTweakSystemPowerFactors(GuiContainer* owner);

    void open(P<SpaceObject> target) override;
    void onDraw(sf::RenderTarget& window) override;
};

class GuiShipTweakPlayer : public GuiTweakPage
{
private:
    P<PlayerSpaceship> target;

    GuiTextEntry* control_code;
    GuiSlider* reputation_point_slider;
    GuiSlider* energy_level_slider;
    GuiSlider* max_energy_level_slider;
    GuiSlider* combat_maneuver_boost_speed_slider;
    GuiSlider* combat_maneuver_strafe_speed_slider;
    GuiLabel* position_count;
    GuiKeyValueDisplay* position[max_crew_positions];
public:
    GuiShipTweakPlayer(GuiContainer* owner);

    virtual void open(P<SpaceObject> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};

class GuiShipTweakPlayer2 : public GuiTweakPage
{
private:
    P<PlayerSpaceship> target;

    GuiSlider* coolant_slider;
    GuiSlider* max_scan_probes_slider;
    GuiSlider* scan_probes_slider;
    GuiToggleButton* can_scan;
    GuiToggleButton* can_hack;
    GuiToggleButton* can_dock;
    GuiToggleButton* can_combat_maneuver;
    GuiToggleButton* can_self_destruct;
    GuiToggleButton* can_launch_probe;
    GuiToggleButton* auto_coolant_enabled;
    GuiToggleButton* auto_repair_enabled;
public:
    GuiShipTweakPlayer2(GuiContainer* owner);

    virtual void open(P<SpaceObject> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};

class GuiObjectTweakBase : public GuiTweakPage
{
private:
    P<SpaceObject> target;

    GuiTextEntry* callsign;
    GuiTextEntry* unscanned_description;
    GuiTextEntry* friend_or_foe_description;
    GuiTextEntry* simple_scan_description;
    GuiTextEntry* full_scan_description;
    GuiSlider* heading_slider;
    GuiSlider* scanning_complexity_slider;
    GuiSlider* scanning_depth_slider;
public:
    GuiObjectTweakBase(GuiContainer* owner);

    virtual void open(P<SpaceObject> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};
#endif//TWEAK_H
