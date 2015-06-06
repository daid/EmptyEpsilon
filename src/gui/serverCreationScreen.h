#ifndef SERVER_CREATION_SCREEN_H
#define SERVER_CREATION_SCREEN_H

#include "gui.h"
#include "gui2.h"
#include "playerInfo.h"

class ScenarioInfo
{
public:
    string filename;
    string name;
    string description;
};

class ServerCreationScreen : public GUI  //Server only
{
    std::vector<ScenarioInfo> scenarios;
    unsigned int active_scenario_index;
public:
    ServerCreationScreen();
    
    virtual void onGui();

private:
    void startScenario();   //Server only
};

#endif//SERVER_CREATION_SCREEN_H
