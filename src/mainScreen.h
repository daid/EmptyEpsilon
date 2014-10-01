#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "gui.h"
#include "mainUIBase.h"

class MainScreenBaseUI : public MainUIBase
{
public:
    MainScreenBaseUI();
    
    virtual void destroy();
};

class MainScreenUI : public MainScreenBaseUI
{
public:
    MainScreenUI() {}
    
    virtual void onGui();
    
    void renderTactical(sf::RenderTarget& window);
    void renderLongRange(sf::RenderTarget& window);
};

class ShipWindowUI : public MainScreenBaseUI
{
public:
    float window_angle;
    
    ShipWindowUI();
    
    virtual void onGui();
};

class TopDownUI : public MainScreenBaseUI
{
public:
    TopDownUI() {}
    
    virtual void onGui();
};

#endif//MAIN_SCREEN_H
