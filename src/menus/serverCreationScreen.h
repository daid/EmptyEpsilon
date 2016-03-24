#ifndef SERVER_CREATION_SCREEN_H
#define SERVER_CREATION_SCREEN_H

#include "gui/gui2.h"
#include "playerInfo.h"

// ServerCreationScreen is only created when you are the server.
class ServerCreationScreen : public GuiCanvas
{
    string selected_scenario_filename;
    GuiScrollText* scenario_description;
    
    GuiElement* variation_container;
    std::vector<string> variation_names_list;
    std::vector<string> variation_descriptions_list;
    GuiSelector* variation_selection;
    GuiScrollText* variation_description;
public:
    ServerCreationScreen();

private:
    void selectScenario(string filename);
    void startScenario();   //Server only
};

#endif//SERVER_CREATION_SCREEN_H
