#ifndef GAME_MASTER_UI_H
#define GAME_MASTER_UI_H

#include "mainUIBase.h"
#include "playerInfo.h"
#include "spaceship.h"

enum EClickAndDragState
{
    CD_None,
    CD_BoxSelect,
    CD_DragObjects
};

class GameMasterUI : public MainUIBase
{
    unsigned int current_faction;
    EClickAndDragState click_and_drag_state;
    sf::Vector2f mouse_down_pos;
    sf::Vector2f prev_mouse_pos;
    sf::Vector2f view_position;
    float view_distance;
    PVector<SpaceObject> selection;
    bool allow_object_drag;
public:
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

#endif//GAME_MASTER_UI_H
