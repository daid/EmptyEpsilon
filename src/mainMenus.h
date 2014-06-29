#ifndef MAIN_MENUS_H
#define MAIN_MENUS_H

#include "gui.h"

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

#endif//MAIN_MENUS_H
