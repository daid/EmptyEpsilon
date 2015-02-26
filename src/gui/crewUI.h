#ifndef CREW_UI_H
#define CREW_UI_H

#include "gui/mainUIBase.h"
#include "playerInfo.h"
#include "spaceObjects/spaceship.h"
#include "repairCrew.h"

class CrewUI : public MainUIBase
{
public:
    CrewUI();

    virtual void onGui();
    virtual void onCrewUI();

    void impulseSlider(sf::FloatRect rect, float text_size);
    void warpSlider(sf::FloatRect rect, float text_size);
    void jumpSlider(float& jump_distance, sf::FloatRect rect, float text_size);
    void jumpButton(float jump_distance, sf::FloatRect rect, float text_size);
    void dockingButton(sf::FloatRect rect, float text_size);
    void weaponTube(EMissileWeapons load_type, int n, float missile_target_angle, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size);
    int frequencyCurve(sf::FloatRect rect, bool frequency_is_beam, bool more_damage_is_positive, int frequency);
    void damagePowerDisplay(sf::FloatRect rect, ESystem system, float text_size);
    
    string onScreenKeyboard();
};

#endif//CREW_UI_H
