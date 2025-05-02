#ifndef AUTO_CONNECT_SCREEN_H
#define AUTO_CONNECT_SCREEN_H

#include "gui/gui2_canvas.h"
#include "playerInfo.h"
#include "io/network/address.h"
#include "preferenceManager.h"

class GuiLabel;
class ServerScanner;

struct AutoConnectPosition
{
    CrewPositions crew_positions = {};
    bool is_main_screen = false;
    bool is_ship_window = false;
    int ship_window_angle = 0;

public:
    AutoConnectPosition(string value);

    string describe();
};

class AutoConnectScreen : public GuiCanvas, public Updatable
{
    P<ServerScanner> scanner;
    sp::io::network::Address connect_to_address;
    std::vector<AutoConnectPosition> positions;
    bool control_main_screen;
    std::map<string, string> ship_filters;
    bool tried_password = false;

    GuiLabel* status_label;
public:
    AutoConnectScreen(std::vector<AutoConnectPosition> positions, bool control_main_screen, string ship_filter);
    virtual ~AutoConnectScreen();

    virtual void update(float delta) override;

private:
    bool isValidShip(sp::ecs::Entity ship);
    void connectToShip(sp::ecs::Entity ship);
};

#endif//AUTO_CONNECT_SCREEN_H
