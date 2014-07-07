#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "gui.h"
#include "mainUIBase.h"

class MainScreenUI : public MainUIBase
{
public:
    MainScreenUI();
    
    virtual void onGui();
    virtual void destroy();
    
    void renderTactical(sf::RenderTarget& window);
    void renderLongRange(sf::RenderTarget& window);
};

#endif//MAIN_SCREEN_H
