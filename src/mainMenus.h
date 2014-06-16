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
    P<ServerScanner> scanner;
    unsigned int selectionIndex;
public:
    ServerBrowserMenu();
    
    virtual void onGui();
};

class JoinServerScreen : public GUI
{
public:
    JoinServerScreen();

    virtual void onGui();
};

#endif//MAIN_MENUS_H
