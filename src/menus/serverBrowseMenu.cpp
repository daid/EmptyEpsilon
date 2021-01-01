#include <i18n.h>
#include "main.h"
#include "serverBrowseMenu.h"
#include "joinServerMenu.h"
#include "preferenceManager.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_button.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_listbox.h"

ServerBrowserMenu::ServerBrowserMenu(SearchSource source)
{
    scanner = new ServerScanner(VERSION_NUMBER);

    if (source == Local)
        scanner->scanLocalNetwork();
    else
        scanner->scanMasterServer(PreferencesManager::get("registry_list_url", "http://daid.eu/ee/list.php"));

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    (new GuiButton(this, "BACK", tr("screenLan", "Back"), [this]() {
        destroy();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

    lan_internet_selector = new GuiSelector(this, "LAN_INTERNET_SELECT", [this](int index, string value) {
        if (index == 0)
            scanner->scanLocalNetwork();
        else
            scanner->scanMasterServer(PreferencesManager::get("registry_list_url", "http://daid.eu/ee/list.php"));
    });
    lan_internet_selector->setOptions({tr("LAN"), tr("Internet")})->setSelectionIndex(source == Local ? 0 : 1)->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    connect_button = new GuiButton(this, "CONNECT", tr("screenLan", "Connect"), [this]() {
        new JoinServerScreen(lan_internet_selector->getSelectionIndex() == 0 ? Local : Internet, sf::IpAddress(manual_ip->getText()));
        destroy();
    });
    connect_button->setPosition(-50, -50, ABottomRight)->setSize(300, 50);

    manual_ip = new GuiTextEntry(this, "IP", "");
    manual_ip->setPosition(-50, -120, ABottomRight)->setSize(300, 50);
    manual_ip->enterCallback([this](string text) {
        new JoinServerScreen(lan_internet_selector->getSelectionIndex() == 0 ? Local : Internet, sf::IpAddress(text.strip()));
        destroy();
    });
    server_list = new GuiListbox(this, "SERVERS", [this](int index, string value) {
        manual_ip->setText(value);
    });
    if (PreferencesManager::get("last_server", "") != "") {
        server_list->addEntry(tr("Last Session ({last})").format({{"last", PreferencesManager::get("last_server", "")}}),
            PreferencesManager::get("last_server", ""));
    }
    scanner->addCallbacks([this](sf::IpAddress address, string name) {
        //New server found
        server_list->addEntry(name + " (" + address.toString() + ")", address.toString());

        if (manual_ip->getText() == "")
            manual_ip->setText(address.toString());

    }, [this](sf::IpAddress address) {
        //Server removed from list
        server_list->removeEntry(server_list->indexByValue(address.toString()));
    });
    server_list->setPosition(0, 50, ATopCenter)->setSize(700, 600);
}

ServerBrowserMenu::~ServerBrowserMenu()
{
    scanner->destroy();
}
