#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "mainUIBase.h"

class MainScreenBaseUI : public MainUIBase
{
private:
    float return_to_ship_selection_time;
public:
    MainScreenBaseUI();
    
    virtual void onGui();
    
    virtual void destroy();
};

class TopDownUI : public MainScreenBaseUI
{
public:
    TopDownUI() {}
    
    virtual void onGui();
};

#endif//MAIN_SCREEN_H
