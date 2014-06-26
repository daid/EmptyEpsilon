#ifndef GAME_MASTER_UI_H
#define GAME_MASTER_UI_H

#include "mainUI.h"
#include "playerInfo.h"
#include "spaceship.h"

class GameMasterUI : public MainUI
{
    int current_faction;
    sf::Vector2f mouse_down_pos;
    sf::Vector2f prev_mouse_pos;
    sf::Vector2f view_position;
    float view_distance;
    P<SpaceObject> selection;
public:
    GameMasterUI();
    
    virtual void onGui();
};

#endif//GAME_MASTER_UI_H
