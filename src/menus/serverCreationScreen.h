#ifndef SERVER_CREATION_SCREEN_H
#define SERVER_CREATION_SCREEN_H

#include "gui/gui2.h"
#include "playerInfo.h"

// ServerCreationScreen is only created when you are the server.
class ServerCreationScreen : public GuiCanvas
{
    string selected_scenario_filename;
public:
    ServerCreationScreen();
    
private:
    void startScenario();   //Server only
};

#endif//SERVER_CREATION_SCREEN_H
