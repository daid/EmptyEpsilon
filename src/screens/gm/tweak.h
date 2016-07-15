#ifndef TWEAK_H
#define TWEAK_H

#include "gui/gui2_panel.h"
#include "missileWeaponData.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

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
    TW_Ship,    // Ships
    TW_Station, // TODO: Space stations
    TW_Player   // Player ships
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

class GuiShipTweakBase : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiTextEntry* type_name;
    GuiTextEntry* callsign;
    GuiTextEntry* description;
    GuiToggleButton* warp_toggle;
    GuiToggleButton* jump_toggle;
    GuiSlider* impulse_speed_slider;
    GuiSlider* turn_speed_slider;
    GuiSlider* heading_slider;
    GuiSlider* hull_max_slider;
    GuiSlider* hull_slider;
public:
    GuiShipTweakBase(GuiContainer* owner);

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
    GuiToggleButton* allowed_use[MW_Count];
public:
    GuiShipTweakMissileTubes(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    
    virtual void open(P<SpaceObject> target) override;
};

class GuiShipTweakShields : public GuiTweakPage
{
private:
    P<SpaceShip> target;

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
    GuiSlider* system_heat[SYS_COUNT];

public:
    GuiShipTweakSystems(GuiContainer* owner);

    virtual void open(P<SpaceObject> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};

class GuiShipTweakPlayer : public GuiTweakPage
{
private:
    P<PlayerSpaceship> target;

    GuiTextEntry* control_code;
    GuiSlider* reputation_point_slider;
    GuiSlider* energy_level_slider;
    GuiSlider* max_energy_level_slider;
    GuiLabel* position_count;
    GuiKeyValueDisplay* position[max_crew_positions];
public:
    GuiShipTweakPlayer(GuiContainer* owner);

    virtual void open(P<SpaceObject> target);

    virtual void onDraw(sf::RenderTarget& window) override;
};

class GuiObjectTweakBase : public GuiTweakPage
{
private:
    P<SpaceObject> target;

    GuiTextEntry* callsign;
    GuiTextEntry* description;
    GuiSlider* heading_slider;
public:
    GuiObjectTweakBase(GuiContainer* owner);

    virtual void open(P<SpaceObject> target);

    virtual void onDraw(sf::RenderTarget& window) override;
};
#endif//TWEAK_H
