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
private:
    //Members
    ECrewPosition show_position;
    EMissileWeapons tube_load_type;
    float jump_distance;
    P<RepairCrew> selected_crew;
    
    ESystem engineering_selected_system;
    int engineering_shield_new_frequency;

    P<SpaceObject> scienceTarget;
    float science_radar_distance;
    bool science_show_radar;
    ScienceDatabaseType science_database_type;
    int science_sub_selection;

    CommsOpenChannelType comms_open_channel_type;
    string comms_player_message;
public:
    CrewUI();

    virtual void onGui();

    void helmsUI();
    void weaponsUI();
    void engineeringUI();
    void scienceUI();
    void commsUI();

    void singlePilotUI();

    void impulseSlider(sf::FloatRect rect, float text_size);
    void warpSlider(sf::FloatRect rect, float text_size);
    void jumpSlider(sf::FloatRect rect, float text_size);
    void jumpButton(sf::FloatRect rect, float text_size);
    void dockingButton(sf::FloatRect rect, float text_size);
    void weaponTube(int n, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size);
    int frequencyCurve(sf::FloatRect rect, bool frequency_is_beam, bool more_damage_is_positive, int frequency);
};

#endif//CREW_UI_H
