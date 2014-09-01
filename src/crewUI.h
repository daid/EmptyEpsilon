#ifndef CREW_UI_H
#define CREW_UI_H

#include "mainUIBase.h"
#include "playerInfo.h"
#include "spaceship.h"
#include "repairCrew.h"

enum CommsOpenChannelType
{
    OCT_None,
    OCT_Station,
    OCT_FriendlyShip,
    OCT_NeutralShip,
    OCT_EnemyShip,
    OCT_UnknownShip,
    OCT_PlayerShip,
};
enum ScienceDatabaseType
{
    SDT_None,
    SDT_Factions,
    SDT_Ships,
    SDT_Weapons
};

class CrewUI : public MainUIBase
{
public:
    CrewUI();

    virtual void onGui();
    virtual void onCrewUI();

    void singlePilotUI();

    void impulseSlider(sf::FloatRect rect, float text_size);
    void warpSlider(sf::FloatRect rect, float text_size);
    void jumpSlider(float& jump_distance, sf::FloatRect rect, float text_size);
    void jumpButton(float jump_distance, sf::FloatRect rect, float text_size);
    void dockingButton(sf::FloatRect rect, float text_size);
    void weaponTube(EMissileWeapons load_type, int n, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size);
    int frequencyCurve(sf::FloatRect rect, bool frequency_is_beam, bool more_damage_is_positive, int frequency);
};

#endif//CREW_UI_H
