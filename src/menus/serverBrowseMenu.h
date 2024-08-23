#ifndef SERVER_BROWSE_MENU_H
#define SERVER_BROWSE_MENU_H

#include "gui/gui2_canvas.h"
#include "multiplayer_client.h"
#include "multiplayer_server_scanner.h"
#include <optional>

class GuiTextEntry;
class GuiButton;
class GuiListbox;
class GuiSelector;
class ServerScanner;

class ServerBrowserMenu : public GuiCanvas
{
public:
    ServerBrowserMenu(std::optional<GameClient::DisconnectReason> last_attempt = {});
    virtual ~ServerBrowserMenu();

private:
    GuiTextEntry* manual_ip;
    GuiButton* connect_button;
    GuiListbox* server_list_box;

    P<ServerScanner> scanner;
    std::vector<ServerScanner::ServerInfo> server_list;
    std::optional<ServerScanner::ServerInfo> selected_server;

    void updateServerList();
    void connect(string host);
    void connect(const ServerScanner::ServerInfo& info);
};

#endif//SERVER_BROWSE_MENU_H
