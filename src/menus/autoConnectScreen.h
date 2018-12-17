#ifndef AUTO_CONNECT_SCREEN_H
#define AUTO_CONNECT_SCREEN_H

#include "gui/gui2_canvas.h"
#include "playerInfo.h"
#include "shipFilter.h"

class GuiLabel;

class AutoConnectScreen : public GuiCanvas, public Updatable
{
    P<ServerScanner> scanner;
    sf::IpAddress connect_to_address;
    ECrewPosition crew_position;
    bool control_main_screen;
    ShipFilter filter;
    
    GuiLabel* status_label;
public:
    AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen, string ship_filter);
    virtual ~AutoConnectScreen();
    
    virtual void update(float delta);

private:
    void connectToShip(P<PlayerSpaceship> ship);
};

#endif//AUTO_CONNECT_SCREEN_H
