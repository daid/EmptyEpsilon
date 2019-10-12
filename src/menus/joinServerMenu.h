#ifndef JOIN_SERVER_MENU_H
#define JOIN_SERVER_MENU_H

#include "gui/gui2_canvas.h"
#include "serverBrowseMenu.h"

class GuiLabel;
class GuiPanel;
class GuiTextEntry;

class JoinServerScreen : public GuiCanvas, public Updatable
{
    sf::IpAddress ip;
    GuiLabel* status_label;
    GuiPanel* password_entry_box;
    GuiTextEntry* password_entry;
    bool password_focused = false;
    sf::Clock keep_alive_timer;
    
    ServerBrowserMenu::SearchSource source;
public:
    JoinServerScreen(ServerBrowserMenu::SearchSource source, sf::IpAddress ip);

    virtual void update(float delta);
};

#endif//JOIN_SERVER_MENU_H
