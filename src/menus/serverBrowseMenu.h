#ifndef SERVER_BROWSE_MENU_H
#define SERVER_BROWSE_MENU_H

#include "gui/gui2.h"

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
    ServerBrowserMenu(SearchSource source);
    virtual ~ServerBrowserMenu();
};

#endif//SERVER_BROWSE_MENU_H
