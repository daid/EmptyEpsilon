#ifndef MAIN_UI_H
#define MAIN_UI_H

#include "gui.h"

class MainUI : public GUI
{
public:
    virtual void onGui();
    
    void drawStatic();
    void drawHeadingCircle(sf::Vector2f position, float size);
};

#endif//MAIN_UI_H
