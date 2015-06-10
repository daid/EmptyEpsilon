#ifndef MAIN_MENUS_H
#define MAIN_MENUS_H

#include "gui/gui2.h"
#include "playerInfo.h"

class MainMenu : public GuiCanvas
{
public:
    MainMenu();
};

class OptionsMenu : public GuiCanvas
{
public:
    OptionsMenu();
};

class ServerBrowserMenu : public GuiCanvas
{
    GuiTextEntry* manual_ip;
    GuiButton* connect_button;
    GuiListbox* server_list;
    
    P<ServerScanner> scanner;
public:
    ServerBrowserMenu();
    virtual ~ServerBrowserMenu();
};

class JoinServerScreen : public GuiCanvas, public Updatable
{
    sf::IpAddress ip;
    int connect_delay;
public:
    JoinServerScreen(sf::IpAddress ip);

    virtual void update(float delta);
};

class AutoConnectScreen : public GuiCanvas, public Updatable
{
    P<ServerScanner> scanner;
    sf::IpAddress connect_to_address;
    int connect_delay;
    ECrewPosition crew_position;
    bool control_main_screen;
    
    GuiLabel* status_label;
public:
    AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen);
    virtual ~AutoConnectScreen();
    
    virtual void update(float delta);
};

#endif//MAIN_MENUS_H
