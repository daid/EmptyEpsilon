#include "shipSelectionScreen.h"
#include "serverCreationScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "screens/windowScreen.h"
#include "screens/topDownScreen.h"
#include "screens/cinematicViewScreen.h"
#include "screens/gm/gameMasterScreen.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_label.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_listbox.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    //Easiest place to ensure that positional sound is disabled on console views. As soon as a 3D view is rendered positional sound is enabled again.
    soundManager->disablePositionalSound();

    GuiElement* container = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutVerticalColumns);
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    GuiElement* left_container = new GuiElement(container, "");
    GuiElement* right_container = new GuiElement(container, "");

    GuiAutoLayout* stations_layout = new GuiAutoLayout(right_container, "CREW_POSITION_BUTTON_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    stations_layout->setPosition(0, 50, ATopCenter)->setSize(400, 500);
    (new GuiLabel(stations_layout, "CREW_POSITION_SELECT_LABEL", "Select your station", 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    crew_type_selector = new GuiSelector(stations_layout, "CREW_TYPE_SELECTION", [this](int index, string value) {
        updateCrewTypeOptions();
    });
    crew_type_selector->setOptions({"6/5 player crew", "4/3 player crew", "1 player crew/extras", "Alternative options"})->setSize(GuiElement::GuiSizeMax, 50);

    main_screen_button = new GuiToggleButton(stations_layout, "MAIN_SCREEN_BUTTON", "Main screen", [this](bool value) {
        for(int n=0; n<max_crew_positions; n++)
        {
            crew_position_button[n]->setValue(false);
            my_player_info->commandSetCrewPosition(ECrewPosition(n), crew_position_button[n]->getValue());
        }
    });
    main_screen_button->setSize(GuiElement::GuiSizeMax, 50);
    for(int n=0; n<max_crew_positions; n++)
    {
        crew_position_button[n] = new GuiToggleButton(stations_layout, "CREW_" + getCrewPositionName(ECrewPosition(n)) + "_BUTTON", getCrewPositionName(ECrewPosition(n)), [this, n](bool value){
            main_screen_button->setValue(false);
            my_player_info->commandSetCrewPosition(ECrewPosition(n), value);
        });
        crew_position_button[n]->setSize(GuiElement::GuiSizeMax, 50);
        crew_position_button[n]->setIcon(getCrewPositionIcon(ECrewPosition(n)));
    }

    main_screen_controls_button = new GuiToggleButton(stations_layout, "MAIN_SCREEN_CONTROLS_ENABLE", "Main screen controls", [](bool value) {
        my_player_info->commandSetMainScreenControl(value);
    });
    main_screen_controls_button->setValue(my_player_info->main_screen_control)->setSize(GuiElement::GuiSizeMax, 50);
    
    game_master_button = new GuiToggleButton(stations_layout, "GAME_MASTER_BUTTON", "Game master", [this](bool value) {
        window_button->setValue(false);
        topdown_button->setValue(false);
        cinematic_view_button->setValue(false);
    });
    game_master_button->setSize(GuiElement::GuiSizeMax, 50);
    window_button = new GuiToggleButton(stations_layout, "WINDOW_BUTTON", "Ship window", [this](bool value) {
        game_master_button->setValue(false);
        topdown_button->setValue(false);
        cinematic_view_button->setValue(false);
    });
    window_button->setSize(GuiElement::GuiSizeMax, 50);
    window_angle = new GuiSelector(stations_layout, "WINDOW_ANGLE", nullptr);
    for(int n=0; n<360; n+=15)
        window_angle->addEntry(string(n) + " degrees", string(n));
    window_angle->setSelectionIndex(0);
    window_angle->setSize(GuiElement::GuiSizeMax, 50);

    // Top down view button
    topdown_button = new GuiToggleButton(stations_layout, "TOP_DOWN_3D_BUTTON", "Top down 3D", [this](bool value) {
        game_master_button->setValue(false);
        window_button->setValue(false);
        cinematic_view_button->setValue(false);
    });
    topdown_button->setSize(GuiElement::GuiSizeMax, 50);

    // Cinematic view button
    cinematic_view_button = new GuiToggleButton(stations_layout, "CINEMATIC_VIEW_BUTTON", "Cinematic view", [this](bool value) {
        game_master_button->setValue(false);
        window_button->setValue(false);
        topdown_button->setValue(false);
    });
    cinematic_view_button->setSize(GuiElement::GuiSizeMax, 50);
    
    if (game_server)
    {
        (new GuiPanel(left_container, "CREATE_SHIP_BOX"))->setPosition(0, 50, ATopCenter)->setSize(550, 700);
    }
    (new GuiPanel(left_container, "SHIP_SELECTION_BOX"))->setPosition(0, 50, ATopCenter)->setSize(550, 560);
    (new GuiLabel(left_container, "SHIP_SELECTION_LABEL", "Select ship:", 30))->addBackground()->setPosition(0, 50, ATopCenter)->setSize(510, 50);
    no_ships_label = new GuiLabel(left_container, "SHIP_SELECTION_NO_SHIPS_LABEL", "Waiting for server to spawn a ship", 30);
    no_ships_label->setPosition(0, 100, ATopCenter)->setSize(460, 50);
    player_ship_list = new GuiListbox(left_container, "PLAYER_SHIP_LIST", [this](int index, string value) {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship)
        {
            my_player_info->commandSetShipId(ship->getMultiplayerId());
        }else{
            my_player_info->commandSetShipId(-1);
        }
    });
    player_ship_list->setPosition(0, 100, ATopCenter)->setSize(490, 500);


    if (game_server)
    {
        GuiSelector* ship_template_selector = new GuiSelector(left_container, "CREATE_SHIP_SELECTOR", nullptr);
        std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::PlayerShip);
        std::sort(template_names.begin(), template_names.end());
        for(string& template_name : template_names)
        {
            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
            ship_template_selector->addEntry(template_name + " (" + ship_template->getClass() + ":" + ship_template->getSubClass() + ")", template_name);
        }
        ship_template_selector->setSelectionIndex(0);
        ship_template_selector->setPosition(0, 630, ATopCenter)->setSize(490, 50);
        
        (new GuiButton(left_container, "CREATE_SHIP_BUTTON", "Spawn player ship", [this, ship_template_selector]() {
            P<PlayerSpaceship> ship = new PlayerSpaceship();
            if (ship)
            {
                ship->setTemplate(ship_template_selector->getSelectionValue());
                ship->setRotation(random(0, 360));
                ship->target_rotation = ship->getRotation();
                ship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
                my_player_info->commandSetShipId(ship->getMultiplayerId());
            }
        }))->setPosition(0, 680, ATopCenter)->setSize(490, 50);

        (new GuiButton(left_container, "DISCONNECT", "Scenario selection", [this]() {
            destroy();
            new ServerCreationScreen();
        }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);
    }else{
        (new GuiButton(left_container, "DISCONNECT", "Disconnect", [this]() {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);
    }
    ready_button = new GuiButton(right_container, "READY_BUTTON", "Ready", [this]() {this->onReadyClick();});
    ready_button->setPosition(0, -50, ABottomCenter)->setSize(300, 50);
    
    crew_type_selector->setSelectionIndex(0);
    updateCrewTypeOptions();
}

void ShipSelectionScreen::update(float delta)
{
    if (game_client && game_client->getStatus() == GameClient::Disconnected)
    {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
        return;
    }
    
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (player_ship_list->indexByValue(string(n)) == -1)
            {
                int index = player_ship_list->addEntry(ship->getTypeName() + " " + ship->getCallSign(), string(n));
                if (my_spaceship == ship)
                    player_ship_list->setSelectionIndex(index);
            }
        }else{
            if (player_ship_list->indexByValue(string(n)) != -1)
                player_ship_list->removeEntry(player_ship_list->indexByValue(string(n)));
        }
    }
    if (player_ship_list->entryCount() > 0)
    {
        no_ships_label->hide();
    }else{
        no_ships_label->show();
    }
    
    updateReadyButton();
}

void ShipSelectionScreen::updateReadyButton()
{
    if (my_player_info->isMainScreen())
    {
        if (my_spaceship && main_screen_button->isVisible() && main_screen_button->getValue())
            ready_button->enable();
        else if (game_master_button->getValue() || topdown_button->getValue() || cinematic_view_button->getValue())
            ready_button->enable();
        else if (my_spaceship && window_button->getValue())
            ready_button->enable();
        else
            ready_button->disable();
    }else{
        if (my_spaceship)
            ready_button->enable();
        else
            ready_button->disable();
    }
}

void ShipSelectionScreen::updateCrewTypeOptions()
{
    game_master_button->hide();
    window_button->hide();
    window_angle->hide();
    topdown_button->hide();
    cinematic_view_button->hide();
    main_screen_button->setVisible(canDoMainScreen());
    main_screen_button->setValue(false);
    game_master_button->setValue(false);
    window_button->setValue(false);
    topdown_button->setValue(false);
    cinematic_view_button->setValue(false);
    for(int n=0; n<max_crew_positions; n++)
    {
        crew_position_button[n]->setValue(false)->hide();
    }
    switch(crew_type_selector->getSelectionIndex())
    {
    case 0:
        for(int n=helmsOfficer; n<=relayOfficer; n++)
            crew_position_button[n]->show();
        break;
    case 1:
        for(int n=tacticalOfficer; n<=operationsOfficer; n++)
            crew_position_button[n]->show();
        break;
    case 2:
        crew_position_button[singlePilot]->show();
        crew_position_button[damageControl]->show();
        crew_position_button[powerManagement]->show();
        crew_position_button[databaseView]->show();
        break;
    case 3:
        main_screen_button->hide();
        game_master_button->setVisible(game_server);
        window_button->setVisible(canDoMainScreen());
        window_angle->setVisible(canDoMainScreen());
        topdown_button->setVisible(canDoMainScreen());
        cinematic_view_button->setVisible(canDoMainScreen());
        break;
    }
    for(int n=0; n<max_crew_positions; n++)
    {
        if (!crew_position_button[n]->isVisible())
            my_player_info->commandSetCrewPosition(ECrewPosition(n), false);
        else
            crew_position_button[n]->setValue(my_player_info->crew_position[n]);
    }
    updateReadyButton();
}

void ShipSelectionScreen::onReadyClick()
{
    if (game_master_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new GameMasterScreen();
    }else if (window_button->getValue())
    {
        destroy();
        new WindowScreen(window_angle->getSelectionValue().toInt());
    }else if(topdown_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new TopDownScreen();
    }else if(cinematic_view_button->getValue())
    {
        my_player_info->commandSetShipId(-1);
        destroy();
        new CinematicViewScreen();
    }else{
        destroy();
        my_player_info->spawnUI();
    }
}
