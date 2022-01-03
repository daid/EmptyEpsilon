#include "main.h"
#include "epsilonServer.h"
#include "menus/joinServerMenu.h"
#include "menus/serverBrowseMenu.h"
#include "playerInfo.h"
#include "preferenceManager.h"
#include "gameGlobalInfo.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_button.h"

JoinServerScreen::JoinServerScreen(ServerBrowserMenu::SearchSource source, sp::io::network::Address ip, int port)
: ip(ip), port(port)
{
    this->source = source;

    status_label = new GuiLabel(this, "STATUS", tr("connectserver", "Connecting..."), 30);
    status_label->setPosition(0, 300, sp::Alignment::TopCenter)->setSize(0, 50);
    (new GuiButton(this, "BTN_CANCEL", tr("button", "Cancel"), [this]() {
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu(this->source);
    }))->setPosition(50, -50, sp::Alignment::BottomLeft)->setSize(300, 50);

    password_entry_box = new GuiPanel(this, "PASSWORD_ENTRY_BOX");
    password_entry_box->setPosition(0, 350, sp::Alignment::TopCenter)->setSize(600, 100);
    password_entry_box->hide();
    password_entry = new GuiTextEntry(password_entry_box, "PASSWORD_ENTRY", "");
    password_entry->setPosition(20, 0, sp::Alignment::CenterLeft)->setSize(400, 50);
    (new GuiButton(password_entry_box, "PASSWORD_ENTRY_OK", "Ok", [this]()
    {
        password_entry_box->hide();
        password_focused = false;
        game_client->sendPassword(password_entry->getText().upper());
    }))->setPosition(420, 0, sp::Alignment::CenterLeft)->setSize(160, 50);

    new GameClient(VERSION_NUMBER, ip, port);
}

void JoinServerScreen::update(float delta)
{
    switch(game_client->getStatus())
    {
    case GameClient::ReadyToConnect:
    case GameClient::Connecting:
    case GameClient::Authenticating:
        //If we are still trying to connect, do nothing.
        break;
    case GameClient::WaitingForPassword:
        status_label->setText(tr("Please enter the server password:"));
        password_entry_box->show();
        if (!password_focused)
        {
            password_focused = true;
            focus(password_entry);
        }
        break;
    case GameClient::Disconnected:
    {
        auto reason = game_client->getDisconnectReason();
        destroy();
        disconnectFromServer();
        
        new ServerBrowserMenu(this->source, reason);
    }
        
        break;
    case GameClient::Connected:
        if (!this->ip.getHumanReadable().empty())
        {
            string last_server = this->ip.getHumanReadable()[0];
            if (port != defaultServerPort)
                last_server += ":" + string(port);
            PreferencesManager::set("last_server", last_server);
        }
        if (game_client->getClientId() > 0)
        {
            foreach(PlayerInfo, i, player_info_list)
                if (i->client_id == game_client->getClientId())
                    my_player_info = i;
            if (my_player_info && gameGlobalInfo)
            {
                returnToShipSelection();
                destroy();
            }
        }
        break;
    }
}
