#ifndef MAIN_UI_H
#define MAIN_UI_H

#include "gui/gui.h"
#include "spaceObjects/spaceship.h"

class ScanGhost
{
public:
    sf::Vector2f position;
    P<SpaceObject> object;
};

class MainUIBase : public GUI, public Updatable
{
    double projection_matrix[16];
    double model_matrix[16];
    double viewport[4];
public:
    float scan_angle;
    std::vector<ScanGhost> scan_ghost;
    string self_destruct_input;

    MainUIBase();

    virtual void onGui();
    virtual void update(float delta);
    virtual void onPauseHelpGui() {}
    
    void mainScreenSelectGUI();
    void selfDestructGUI();
    void drawStatic(float alpha=1.0);
    void drawRaderBackground(sf::Vector2f view_position, sf::Vector2f position, float size, float range, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawHeadingCircle(sf::Vector2f position, float size, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawRadarCuttoff(sf::Vector2f position, float size, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawWaypoints(sf::Vector2f view_position, sf::Vector2f position, float size, float range);
    void drawRadarSweep(sf::Vector2f position, float range, float size, float angle);
    void drawRadar(sf::Vector2f position, float size, float range, bool long_range, P<SpaceObject> target, sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900));
    void drawShipInternals(sf::Vector2f position, P<SpaceShip> ship, ESystem highlight_system);
    void drawUILine(sf::Vector2f start, sf::Vector2f end, float x_split);
    void draw3Dworld(sf::FloatRect rect = sf::FloatRect(0, 0, getWindowSize().x, 900), bool show_callsigns=true);
    void draw3Dheadings(float distance=2500.0f);
    
    sf::Vector3f worldToScreen(sf::Vector3f world);
};

#endif//MAIN_UI_H
