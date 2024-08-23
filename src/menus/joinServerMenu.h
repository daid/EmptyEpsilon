#ifndef JOIN_SERVER_MENU_H
#define JOIN_SERVER_MENU_H

#include "gui/gui2_canvas.h"
#include "multiplayer_server_scanner.h"


class GuiLabel;
class GuiPanel;
class GuiTextEntry;

class JoinServerScreen : public GuiCanvas, public Updatable
{
public:
    JoinServerScreen(const ServerScanner::ServerInfo& target);

    virtual void update(float delta) override;

private:
    ServerScanner::ServerInfo target;
    GuiLabel* status_label;
    GuiPanel* password_entry_box;
    GuiTextEntry* password_entry = nullptr;
    bool password_focused = false;
};

#endif//JOIN_SERVER_MENU_H
