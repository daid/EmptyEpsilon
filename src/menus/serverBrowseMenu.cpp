#include "main.h"
#include "serverBrowseMenu.h"
#include "joinServerMenu.h"

ServerBrowserMenu::ServerBrowserMenu(SearchSource source)
{
    scanner = new ServerScanner(VERSION_NUMBER);
    if (source == Local)
        scanner->scanLocalNetwork();
    else
        scanner->scanMasterServer("http://daid.eu/ee/list.php");

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    (new GuiButton(this, "BACK", "Back", [this]() {
        destroy();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(300, 50);

    connect_button = new GuiButton(this, "CONNECT", "Connect", [this, source]() {
        new JoinServerScreen(source, sf::IpAddress(manual_ip->getText()));
        destroy();
    });
    connect_button->setPosition(-50, -50, ABottomRight)->setSize(300, 50);
    
    manual_ip = new GuiTextEntry(this, "IP", "");
    manual_ip->setPosition(-50, -120, ABottomRight)->setSize(300, 50);
    
    server_list = new GuiListbox(this, "SERVERS", [this](int index, string value) {
        manual_ip->setText(value);
    });
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
