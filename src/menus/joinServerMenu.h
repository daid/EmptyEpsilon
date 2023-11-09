#ifndef JOIN_SERVER_MENU_H
#define JOIN_SERVER_MENU_H

#include "gui/gui2_canvas.h"
#include "serverBrowseMenu.h"
#include "io/network/address.h"


class GuiLabel;
class GuiPanel;
class GuiTextEntry;

class JoinServerScreen : public GuiCanvas, public Updatable
{
    sp::io::network::Address ip;
    int port = 0;
    GuiLabel* status_label;
    GuiPanel* password_entry_box;
    GuiTextEntry* password_entry = nullptr;
    bool password_focused = false;

    ServerBrowserMenu::SearchSource source;

    JoinServerScreen(ServerBrowserMenu::SearchSource source);
public:
    JoinServerScreen(ServerBrowserMenu::SearchSource source, sp::io::network::Address ip, int port);
#ifdef STEAMSDK
    JoinServerScreen(ServerBrowserMenu::SearchSource source, uint64_t steam_id);
#endif

    virtual void update(float delta) override;
};

#endif//JOIN_SERVER_MENU_H
