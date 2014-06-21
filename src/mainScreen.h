#ifndef MAIN_SCREEN_H
#define MAIN_SCREEN_H

#include "gui.h"
#include "mainUI.h"

class MainScreenUI : public MainUI
{
public:
    MainScreenUI();
    
    virtual void onGui();
    virtual void destroy();
    
    void render3dView(sf::RenderTarget& window);
    void renderTactical(sf::RenderTarget& window);
    void renderLongRange(sf::RenderTarget& window);
};

#endif//MAIN_SCREEN_H
