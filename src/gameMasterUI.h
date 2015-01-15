#ifndef GAME_MASTER_UI_H
#define GAME_MASTER_UI_H

#include "mainUIBase.h"
#include "playerInfo.h"
#include "spaceship.h"

enum EMouseMode
{
    MM_None,
    MM_Drag,
    MM_Create
};
enum EClickAndDragState
{
    CD_None,
    CD_BoxSelect,
    CD_DragObjects
};

class GameMasterUI : public MainUIBase
{
    EMouseMode mouse_mode;
    EClickAndDragState click_and_drag_state;
    sf::Vector2f mouse_down_pos;
    sf::Vector2f prev_mouse_pos;
    sf::Vector2f view_position;
    float view_distance;
    PVector<SpaceObject> selection;
public:
    string create_object_script;
    
    GameMasterUI();
    
    virtual void onGui();
};

class GameMasterShipRetrofit : public GUI
{
private:
    P<SpaceShip> ship;
public:
    GameMasterShipRetrofit(P<SpaceShip> ship);
    virtual void onGui();
};

class GameMasterGlobalMessageEntry : public GUI
{
    string message;
public:
    virtual void onGui();
};

class GameMasterCreateObjectWindow : public GUI
{
    static unsigned int current_faction;
    
    P<GameMasterUI> ui;
public:
    GameMasterCreateObjectWindow(P<GameMasterUI> ui);

    virtual void onGui();
};

class GameMasterHailUI : public GUI
{
    string hail_name;
    string comms_message;
    P<PlayerSpaceship> player;
public:
    GameMasterHailUI(P<PlayerSpaceship> player);

    virtual void onGui();
};

#endif//GAME_MASTER_UI_H
