#ifndef AUTO_CONNECT_SCREEN_H
#define AUTO_CONNECT_SCREEN_H

#include "gui/gui2_canvas.h"
#include "playerInfo.h"

class GuiLabel;

class AutoConnectScreen : public GuiCanvas, public Updatable
{
    P<ServerScanner> scanner;
    sf::IpAddress connect_to_address;
    ECrewPosition crew_position;
    bool control_main_screen;
    int ship_index;
    
    GuiLabel* status_label;
public:
    AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen, int ship_index);
    virtual ~AutoConnectScreen();
    
    virtual void update(float delta);

private:
    void checkForPlayerShip(int index);
};

#endif//AUTO_CONNECT_SCREEN_H
