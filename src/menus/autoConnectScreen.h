#ifndef AUTO_CONNECT_SCREEN_H
#define AUTO_CONNECT_SCREEN_H

#include "gui/gui2_canvas.h"
#include "playerInfo.h"
#include "io/network/address.h"

class GuiLabel;
class ServerScanner;

class AutoConnectScreen : public GuiCanvas, public Updatable
{
    P<ServerScanner> scanner;
    sp::io::network::Address connect_to_address;
    ECrewPosition crew_position;
    bool control_main_screen;
    std::map<string, string> ship_filters;

    GuiLabel* status_label;
public:
    AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen, string ship_filter);
    virtual ~AutoConnectScreen();

    virtual void update(float delta) override;

private:
    bool isValidShip(int index);
    void connectToShip(int index);
};

#endif//AUTO_CONNECT_SCREEN_H
