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

JoinServerScreen::JoinServerScreen(ServerBrowserMenu::SearchSource source, sf::IpAddress ip)
: ip(ip)
{
    this->source = source;

    status_label = new GuiLabel(this, "STATUS", "Connecting...", 30);
    status_label->setPosition(0, 300, ATopCenter)->setSize(0, 50);
    (new GuiButton(this, "BTN_CANCEL", "Cancel", [this]() {
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu(this->source);
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

    password_entry_box = new GuiPanel(this, "PASSWORD_ENTRY_BOX");
    password_entry_box->setPosition(0, 350, ATopCenter)->setSize(600, 100);
    password_entry_box->hide();
    password_entry = new GuiTextEntry(password_entry_box, "PASSWORD_ENTRY", "");
    password_entry->setPosition(20, 0, ACenterLeft)->setSize(400, 50);
    (new GuiButton(password_entry_box, "PASSWORD_ENTRY_OK", "Ok", [this]()
    {
        password_entry_box->hide();
        password_focused = false;
        game_client->sendPassword(password_entry->getText().upper());
    }))->setPosition(420, 0, ACenterLeft)->setSize(160, 50);
    
    new GameClient(VERSION_NUMBER, ip);
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
        if (keep_alive_timer.getElapsedTime().asSeconds() > 10) {
            keep_alive_timer.restart();
            game_client->keepAlive();
        }
        status_label->setText("Please enter the server password:");
        password_entry_box->show();
        if (!password_focused)
        {
            password_focused = true;
            focus(password_entry);
        }
        break;
    case GameClient::Disconnected:
        destroy();
        disconnectFromServer();
        new ServerBrowserMenu(this->source);
        break;
    case GameClient::Connected:
        PreferencesManager::set("last_server", this->ip.toString());
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
