#ifndef GAME_MASTER_UI_H
#define GAME_MASTER_UI_H

#include "mainUI.h"
#include "playerInfo.h"
#include "spaceship.h"

class GameMasterUI : public MainUI
{
    sf::Vector2f prev_mouse_pos;
    sf::Vector2f view_position;
    float view_distance;
public:
    GameMasterUI();
    
    virtual void onGui();
};

#endif//GAME_MASTER_UI_H
