#ifndef GAME_MASTER_TWEAK_H
#define GAME_MASTER_TWEAK_H

#include "gui/gui2.h"
#include "spaceObjects/spaceship.h"

class GuiTweakPage : public GuiElement
{
public:
    GuiTweakPage(GuiContainer* owner) : GuiElement(owner, "") {}

    virtual void open(P<SpaceShip> target) = 0;
};

class GuiShipTweak : public GuiPanel
{
public:
    GuiShipTweak(GuiContainer* owner);
    
    void open(P<SpaceShip> target);

    virtual void onDraw(sf::RenderTarget& window) override;
private:
    P<SpaceShip> target;
    std::vector<GuiTweakPage*> pages;
};

class GuiShipTweakBase : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiTextEntry* type_name;
    GuiSelector* warp_selector;
    GuiSelector* jump_selector;
    GuiSlider* impulse_speed_slider;
    GuiSlider* turn_speed_slider;
    GuiSlider* hull_max_slider;
    GuiSlider* hull_slider;
public:
    GuiShipTweakBase(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    
    virtual void open(P<SpaceShip> target) override;
};

class GuiShipTweakMissileWeapons : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiSelector* missile_tube_amount_selector;
    GuiSelector* missile_storage_amount_selector[MW_Count];
    GuiSelector* missile_current_amount_selector[MW_Count];
public:
    GuiShipTweakMissileWeapons(GuiContainer* owner);

    virtual void onDraw(sf::RenderTarget& window) override;
    
    virtual void open(P<SpaceShip> target) override;
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
    
    virtual void open(P<SpaceShip> target) override;
};

class GuiShipTweakSystems : public GuiTweakPage
{
private:
    P<SpaceShip> target;

    GuiSlider* system_damage[SYS_COUNT];
    GuiSlider* system_heat[SYS_COUNT];

public:
    GuiShipTweakSystems(GuiContainer* owner);

    virtual void open(P<SpaceShip> target) override;

    virtual void onDraw(sf::RenderTarget& window) override;
};

#endif//GAME_MASTER_TWEAK_H
