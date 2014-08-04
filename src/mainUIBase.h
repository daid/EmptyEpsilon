#ifndef MAIN_UI_H
#define MAIN_UI_H

#include "gui.h"
#include "spaceship.h"

class MainUIBase : public GUI
{
public:
    virtual void onGui();
    
    void mainScreenSelectGUI();
    void drawStatic(float alpha=1.0);
    void drawRaderBackground(sf::Vector2f view_position, sf::Vector2f position, float size, float scale, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawHeadingCircle(sf::Vector2f position, float size, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawRadarCuttoff(sf::Vector2f position, float size, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawRadar(sf::Vector2f position, float size, float range, bool long_range, P<SpaceObject> target, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawShipInternals(sf::Vector2f position, P<SpaceShip> ship, ESystem highlight_system);
    void draw3Dworld(sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
};

#endif//MAIN_UI_H
