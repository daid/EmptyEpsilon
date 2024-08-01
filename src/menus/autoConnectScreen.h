#ifndef AUTO_CONNECT_SCREEN_H
#define AUTO_CONNECT_SCREEN_H

#include "gui/gui2_canvas.h"
#include "playerInfo.h"
#include "io/network/address.h"
#include "preferenceManager.h"

class GuiLabel;
class ServerScanner;

class AutoConnectScreen : public GuiCanvas, public Updatable
{
    P<ServerScanner> scanner;
    sp::io::network::Address connect_to_address;
    CrewPosition crew_position;
    bool control_main_screen;
    std::map<string, string> ship_filters;

    GuiLabel* status_label;
    int crew_position_raw = (PreferencesManager::get("autoconnect").toInt());
public:
    AutoConnectScreen(CrewPosition crew_position, bool control_main_screen, string ship_filter);
    virtual ~AutoConnectScreen();

    virtual void update(float delta) override;

private:
    bool isValidShip(sp::ecs::Entity ship);
    void connectToShip(sp::ecs::Entity ship);
};

#endif//AUTO_CONNECT_SCREEN_H
