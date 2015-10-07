#include "shipSelectionScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "screens/windowScreen.h"
#include "screens/topDownScreen.h"
#include "screens/gameMasterScreen.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    //Easiest place to ensure that positional sound is disabled on console views. As soon as a 3D view is rendered positional sound is enabled again.
    soundManager->disablePositionalSound();

    (new GuiLabel(this, "CREW_POSITION_SELECT_LABEL", "Select your station", 30))->addBox()->setPosition(-50, 50, ATopRight)->setSize(460, 50);
    (new GuiBox(this, "CREW_POSITION_SELECT_BOX"))->setPosition(-50, 50, ATopRight)->setSize(460, 560);
    
    GuiAutoLayout* stations_layout = new GuiAutoLayout(this, "CREW_POSITION_BUTTON_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    stations_layout->setPosition(-80, 100, ATopRight)->setSize(400, 500);
    main_screen_button = new GuiToggleButton(stations_layout, "MAIN_SCREEN_BUTTON", "Main screen", [this](bool value) {
        for(int n=0; n<max_crew_positions; n++)
        {
            crew_position_button[n]->setValue(false);
            my_player_info->setCrewPosition(ECrewPosition(n), crew_position_button[n]->getValue());
        }
        updateReadyButton();
    });
    main_screen_button->setSize(GuiElement::GuiSizeMax, 50);
    for(int n=0; n<max_crew_positions; n++)
    {
        crew_position_button[n] = new GuiToggleButton(stations_layout, "CREW_" + getCrewPositionName(ECrewPosition(n)) + "_BUTTON", getCrewPositionName(ECrewPosition(n)), [this, n](bool value){
            main_screen_button->setValue(false);
            my_player_info->setCrewPosition(ECrewPosition(n), value);
            updateReadyButton();
        });
        crew_position_button[n]->setSize(GuiElement::GuiSizeMax, 50);
    }

    main_screen_controls_button = new GuiToggleButton(stations_layout, "MAIN_SCREEN_CONTROLS_ENABLE", "Main screen controls", [](bool value) {
        my_player_info->setMainScreenControl(value);
    });
    main_screen_controls_button->setValue(my_player_info->main_screen_control)->setSize(GuiElement::GuiSizeMax, 50);
    
    game_master_button = new GuiToggleButton(stations_layout, "GAME_MASTER_BUTTON", "Game master", [this](bool value) {
        window_button->setValue(false);
        topdown_button->setValue(false);
        updateReadyButton();
    });
    game_master_button->setSize(GuiElement::GuiSizeMax, 50);
    window_button = new GuiToggleButton(stations_layout, "WINDOW_BUTTON", "Ship window", [this](bool value) {
        game_master_button->setValue(false);
        topdown_button->setValue(false);
        updateReadyButton();
    });
    window_button->setSize(GuiElement::GuiSizeMax, 50);
    window_angle = new GuiSelector(stations_layout, "WINDOW_ANGLE", nullptr);
    for(int n=0; n<360; n+=15)
        window_angle->addEntry(string(n) + " degrees", string(n));
    window_angle->setSelectionIndex(0);
    window_angle->setSize(GuiElement::GuiSizeMax, 50);
    topdown_button = new GuiToggleButton(stations_layout, "TOP_DOWN_3D_BUTTON", "Top down 3D", [this](bool value) {
        game_master_button->setValue(false);
        window_button->setValue(false);
        updateReadyButton();
    });
    topdown_button->setSize(GuiElement::GuiSizeMax, 50);
    
    crew_type_selector = new GuiSelector(this, "CREW_TYPE_SELECTION", [this](int index, string value) {
        updateCrewTypeOptions();
    });
    crew_type_selector->setOptions({"6/5 player crew", "4/3 player crew", "1 player crew", "Alternative options"})->setPosition(-50, 560, ATopRight)->setSize(460, 50);
    
    (new GuiLabel(this, "SHIP_SELECTION_LABEL", "Select ship:", 30))->addBox()->setPosition(50, 50, ATopLeft)->setSize(550, 50);
    no_ships_label = new GuiLabel(this, "SHIP_SELECTION_NO_SHIPS_LABEL", "Waiting for server to spawn a ship", 30);
    no_ships_label->setPosition(80, 100, ATopLeft)->setSize(460, 50);
    (new GuiBox(this, "SHIP_SELECTION_BOX"))->setPosition(50, 50, ATopLeft)->setSize(550, 560);
    player_ship_list = new GuiListbox(this, "PLAYER_SHIP_LIST", [this](int index, string value) {
        my_spaceship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (my_spaceship)
        {
            my_player_info->setShipId(my_spaceship->getMultiplayerId());
        }else{
            my_player_info->setShipId(-1);
        }
        updateReadyButton();
    });
    player_ship_list->setPosition(80, 100, ATopLeft)->setSize(490, 500);


    if (game_server)
    {
        (new GuiBox(this, "CREATE_SHIP_BOX"))->setPosition(50, 50, ATopLeft)->setSize(550, 700);
        GuiSelector* ship_template_selector = new GuiSelector(this, "CREATE_SHIP_SELECTOR", nullptr);
        std::vector<string> template_names = ShipTemplate::getPlayerTemplateNameList();
        std::sort(template_names.begin(), template_names.end());
        ship_template_selector->setOptions(template_names)->setSelectionIndex(0);
        ship_template_selector->setPosition(80, 630, ATopLeft)->setSize(490, 50);
        
        (new GuiButton(this, "CREATE_SHIP_BUTTON", "Spawn player ship", [ship_template_selector]() {
            my_spaceship = new PlayerSpaceship();
            if (my_spaceship)
            {
                my_spaceship->setShipTemplate(ship_template_selector->getSelectionValue());
                my_spaceship->setRotation(random(0, 360));
                my_spaceship->target_rotation = my_spaceship->getRotation();
                my_spaceship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
                my_player_info->setShipId(my_spaceship->getMultiplayerId());
            }
        }))->setPosition(80, 680, ATopLeft)->setSize(490, 50);
    }
    
    (new GuiButton(this, "DISCONNECT", game_server ? "Close server" : "Disconnect", [this]() {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
    }))->setPosition(150, -50, ABottomLeft)->setSize(300, 50);
    ready_button = new GuiButton(this, "READY_BUTTON", "Ready", [this]() {this->onReadyClick();});
    ready_button->setPosition(-150, -50, ABottomRight)->setSize(300, 50);
    
    crew_type_selector->setSelectionIndex(0);
    updateReadyButton();
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
                int index = player_ship_list->addEntry(ship->ship_type_name + " " + ship->getCallSign(), string(n));
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
}

void ShipSelectionScreen::updateButtonStatus(GuiToggleButton* toggled)
{
    updateReadyButton();
}

void ShipSelectionScreen::updateReadyButton()
{
    if (my_player_info->isMainScreen())
    {
        if (my_spaceship && main_screen_button->isVisible() && main_screen_button->getValue())
            ready_button->enable();
        else if (game_master_button->getValue() || topdown_button->getValue())
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
    main_screen_button->setVisible(canDoMainScreen());
    main_screen_button->setValue(false);
    game_master_button->setValue(false);
    window_button->setValue(false);
    topdown_button->setValue(false);
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
        break;
    case 3:
        main_screen_button->hide();
        game_master_button->setVisible(game_server);
        window_button->setVisible(canDoMainScreen());
        window_angle->setVisible(canDoMainScreen());
        topdown_button->setVisible(canDoMainScreen());
        break;
    }
    for(int n=0; n<max_crew_positions; n++)
    {
        if (!crew_position_button[n]->isVisible())
            my_player_info->setCrewPosition(ECrewPosition(n), false);
        else
            crew_position_button[n]->setValue(my_player_info->crew_position[n]);
    }
    updateReadyButton();
}

void ShipSelectionScreen::onReadyClick()
{
    if (game_master_button->getValue())
    {
        my_spaceship = NULL;
        my_player_info->setShipId(-1);
        destroy();
        new GameMasterScreen();
    }else if (window_button->getValue())
    {
        destroy();
        new WindowScreen(window_angle->getSelectionValue().toInt());
    }else if(topdown_button->getValue())
    {
        my_spaceship = NULL;
        my_player_info->setShipId(-1);
        destroy();
        new TopDownScreen();
    }else{
        destroy();
        my_player_info->spawnUI();
    }
}
