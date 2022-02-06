#ifndef SERVER_CREATION_SCREEN_H
#define SERVER_CREATION_SCREEN_H

#include "gui/gui2_canvas.h"
#include "Updatable.h"

class GuiScrollText;
class GuiAutoLayout;
class GuiSelector;
class GuiTextEntry;
class GuiListbox;
class GuiButton;
class GuiLabel;


class ServerSetupScreen : public GuiCanvas
{
public:
    ServerSetupScreen();

private:
    GuiTextEntry* server_name;
    GuiTextEntry* server_password;
    GuiTextEntry* gm_password;
    GuiSelector* server_visibility;
    GuiTextEntry* server_port;
};

class ServerSetupMasterServerRegistrationScreen : public GuiCanvas, Updatable
{
public:
    ServerSetupMasterServerRegistrationScreen();

    virtual void update(float delta) override;

private:
    GuiLabel* info_label;
    GuiButton* continue_button;
};

class ServerScenarioSelectionScreen : public GuiCanvas
{
public:
    ServerScenarioSelectionScreen();

private:
    void loadScenarioList(const string& category);
    GuiListbox* category_list;
    GuiListbox* scenario_list;
    GuiScrollText* description_text;
    GuiButton* start_button;
};

class ServerScenarioOptionsScreen : public GuiCanvas
{
public:
    ServerScenarioOptionsScreen(string filename);

private:
    GuiButton* start_button;
    std::unordered_map<string, GuiScrollText*> description_per_setting;
};

#endif//SERVER_CREATION_SCREEN_H
