#ifndef SERVER_BROWSE_MENU_H
#define SERVER_BROWSE_MENU_H

#include "gui/gui2_canvas.h"

#include <optional>

class GuiTextEntry;
class GuiButton;
class GuiListbox;
class GuiSelector;

class ServerBrowserMenu : public GuiCanvas
{
public:
    enum SearchSource
    {
        Local,
        Internet
    };
private:
    GuiTextEntry* manual_ip;
    GuiButton* connect_button;
    GuiListbox* server_list;
    GuiSelector* lan_internet_selector;

    P<ServerScanner> scanner;
public:
    ServerBrowserMenu(SearchSource source, std::optional<GameClient::DisconnectReason> last_attempt = {});
    virtual ~ServerBrowserMenu();
};

#endif//SERVER_BROWSE_MENU_H
