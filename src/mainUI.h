#ifndef MAIN_UI_H
#define MAIN_UI_H

#include "gui.h"
#include "spaceShip.h"

class MainUI : public GUI
{
public:
    virtual void onGui();
    
    void mainScreenSelectGUI();
    void drawStatic(float alpha=1.0);
    void drawRaderBackground(sf::Vector2f position, float size, float scale);
    void drawHeadingCircle(sf::Vector2f position, float size);
    void drawShipInternals(sf::Vector2f position, P<SpaceShip> ship, ESystem highlight_system);
};

#endif//MAIN_UI_H
