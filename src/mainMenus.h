#ifndef MAIN_MENUS_H
#define MAIN_MENUS_H

#include "gui.h"
#include "playerInfo.h"

class MainMenu : public GUI
{
public:
    MainMenu();
    
    virtual void onGui();
};

class ServerBrowserMenu : public GUI
{
    string manual_ip;
    
    P<ServerScanner> scanner;
    unsigned int selectionIndex;
public:
    ServerBrowserMenu();
    virtual ~ServerBrowserMenu();
    
    virtual void onGui();
};

class JoinServerScreen : public GUI
{
    sf::IpAddress ip;
    int connect_delay;
public:
    JoinServerScreen(sf::IpAddress ip);

    virtual void onGui();
};

class AutoConnectScreen : public GUI
{
    P<ServerScanner> scanner;
    sf::IpAddress connect_to_address;
    int connect_delay;
    ECrewPosition crew_position;
    bool control_main_screen;
public:
    AutoConnectScreen(ECrewPosition crew_position, bool control_main_screen);
    virtual ~AutoConnectScreen();
    
    virtual void onGui();
};

#endif//MAIN_MENUS_H
