#include "shipSelectionScreen.h"
#include "epsilonServer.h"
#include "main.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "mainScreen.h"
#include "crewUI.h"
#include "gameMasterUI.h"

ShipSelectionScreen::ShipSelectionScreen()
{
    //Easiest place to ensure that positional sound is disabled on console views. As soon as a 3D view is rendered positional sound is enabled again.
    soundManager.disablePositionalSound();

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
        crew_position_button[n] = new GuiToggleButton(stations_layout, "CREW_" + string(n) + "_BUTTON", getCrewPositionName(ECrewPosition(n)), [this, n](bool value){
            main_screen_button->setValue(false);
            my_player_info->setCrewPosition(ECrewPosition(n), value);
            updateReadyButton();
        });
        crew_position_button[n]->setSize(GuiElement::GuiSizeMax, 50);
    }
    (new GuiSelector(this, "CREW_TYPE_SELECTION", [this](int index, string value) {
        main_screen_button->setVisible(canDoMainScreen());
        main_screen_button->setValue(false);
        for(int n=0; n<max_crew_positions; n++)
            crew_position_button[n]->setValue(false)->hide();
        switch(index)
        {
        case 0:
            for(int n=helmsOfficer; n<=commsOfficer; n++)
                crew_position_button[n]->show();
            break;
        case 1:
            for(int n=tacticalOfficer; n<=operationsOfficer; n++)
                crew_position_button[n]->show();
            break;
        case 2:
            crew_position_button[singlePilot]->show();
            break;
        }
        updateReadyButton();
    }))->setOptions({"6/5 player crew", "4/3 player crew", "1 player crew", "Alternative options"})->setSelectionIndex(0)->setPosition(-50, 560, ATopRight)->setSize(460, 50);
    
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
        ship_template_selector->setOptions(ShipTemplate::getPlayerTemplateNameList())->setSelectionIndex(0);
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
    ready_button = new GuiButton(this, "READY_BUTTON", "Ready", [this]() {
        my_player_info->spawnUI();
        destroy();
    });
    ready_button->setPosition(-150, -50, ABottomRight)->setSize(300, 50);
    updateReadyButton();
}

void ShipSelectionScreen::update(float delta)
{
    if (game_client && !game_client->isConnected())
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

void ShipSelectionScreen::updateReadyButton()
{
    if (my_spaceship)
        ready_button->enable();
}

/*
void ShipSelectionScreen::onGui()
{
    drawBox(sf::FloatRect(780, 30, 340, 540));
    drawBox(sf::FloatRect(780, 80, 340, 490));

    string selection_title = "???";
    
    switch(screen_selection)
    {
    case SS_6players:
        selection_title = "6/5 player crew";
        selectCrewPosition(true, helmsOfficer, commsOfficer);
        break;
    case SS_4players:
        selection_title = "4/3 player crew";
        selectCrewPosition(true, tacticalOfficer, operationsOfficer);
        break;
    case SS_1player:
        selection_title = "1 player crew";
        selectCrewPosition(false, singlePilot, singlePilot);
        break;
    case SS_Other:
        selection_title = "Alternative options";
        if (game_server)
        {
            if (drawButton(sf::FloatRect(800, 100, 300, 50), "Game Master"))
            {
                my_spaceship = NULL;
                my_player_info->setShipId(-1);
                destroy();
                new GameMasterUI();
            }
        }
        if (my_spaceship)
        {
            if (canDoMainScreen())
            {
                if (drawButton(sf::FloatRect(800, 150, 300, 50), "Window"))
                {
                    destroy();
                    P<ShipWindowUI> ui = new ShipWindowUI();
                    ui->window_angle = window_angle;
                }
                window_angle += drawSelector(sf::FloatRect(800, 200, 300, 50), "Window: " + string(window_angle) + "deg", 30) * 15;
                if (window_angle < 0)
                    window_angle += 360;
                if (window_angle >= 360)
                    window_angle -= 360;

                if (drawButton(sf::FloatRect(800, 250, 300, 50), "Top down 3D"))
                {
                    destroy();
                    new TopDownUI();
                }
            }
        }else{
            drawText(sf::FloatRect(800, 150, 300, 50), "Select a ship", AlignCenter, 30);
        }
        break;
    default:
        break;
    }
    
    int delta = drawSelector(sf::FloatRect(780, 30, 340, 50), selection_title);
    if (delta)
    {
        screen_selection = (EScreenSelection)(screen_selection + delta);
        if (screen_selection == SS_MIN)
            screen_selection = (EScreenSelection)(SS_MAX - 1);
        if (screen_selection == SS_MAX)
            screen_selection = (EScreenSelection)(SS_MIN + 1);
        for(int n=0; n<max_crew_positions; n++)
            my_player_info->setCrewPosition(ECrewPosition(n), false);
    }

    int shipCount = 0;
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship && ship->ship_template)
        {
            if (n < 8)
            {
                if (drawToggleButton(sf::FloatRect(200, 150 + (n % 8) * 50, 300, 50), my_spaceship == ship, ship->ship_type_name + " " + string(n + 1)))
                {
                    my_spaceship = ship;
                    my_player_info->setShipId(my_spaceship->getMultiplayerId());
                }
            }else{
                if (drawToggleButton(sf::FloatRect(200 + 200 + (n / 8) * 100, 150 + (n % 8) * 50, 100, 50), my_spaceship == ship, string(n + 1)))
                {
                    my_spaceship = ship;
                    my_player_info->setShipId(my_spaceship->getMultiplayerId());
                }
            }
            shipCount++;
        }
    }
    if (shipCount == 0)
    {
        drawTextBox(sf::FloatRect(200, 150, 300, 100), "Waiting for server to spawn a ship", AlignCenter, 30);
    }

    if (game_server)
    {
        std::vector<string> templates = ShipTemplate::getPlayerTemplateNameList();
        drawTextBox(sf::FloatRect(200, 50, 300, 50), game_server->getServerName(), AlignCenter);
        drawText(sf::FloatRect(200, 100, 300, 50), sf::IpAddress::getLocalAddress().toString(), AlignCenter, 30);

        if (ship_template_index < int(templates.size()))
        {
            ship_template_index += drawSelector(sf::FloatRect(200, 650, 300, 50), templates[ship_template_index]);
            if (ship_template_index < 0)
                ship_template_index = templates.size() - 1;
            if (ship_template_index >= int(templates.size()))
                ship_template_index = 0;
        }
        if (drawButton(sf::FloatRect(200, 600, 300, 50), "Spawn player ship"))
        {
            my_spaceship = new PlayerSpaceship();
            if (my_spaceship)
            {
                my_spaceship->setShipTemplate(templates[ship_template_index]);
                my_spaceship->setRotation(random(0, 360));
                my_spaceship->target_rotation = my_spaceship->getRotation();
                my_spaceship->setPosition(sf::Vector2f(random(-100, 100), random(-100, 100)));
                my_player_info->setShipId(my_spaceship->getMultiplayerId());
            }
        }
    }

    if (game_server)
    {
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Close server"))
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }
    }else{
        if (drawButton(sf::FloatRect(50, 800, 300, 50), "Disconnect"))
        {
            destroy();
            disconnectFromServer();
            returnToMainMenu();
        }
    }
}

void ShipSelectionScreen::selectCrewPosition(bool main_screen_option, int crew_pos_min, int crew_pos_max)
{
    
    if (my_spaceship)
    {
        int32_t my_ship_id = my_spaceship->getMultiplayerId();

        int main_screen_control_count = 0;
        int main_count = 0;
        foreach(PlayerInfo, i, player_info_list)
        {
            if (i->ship_id == my_ship_id && i->isMainScreen())
                main_count++;
            if (i->ship_id == my_ship_id && i->main_screen_control)
                main_screen_control_count++;
        }

        float y = 100;
        if (main_screen_option)
        {
            if (canDoMainScreen())
            {
                if (drawToggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->isMainScreen(), "Main screen", 30))
                {
                    for(int n=0; n<max_crew_positions; n++)
                        my_player_info->setCrewPosition(ECrewPosition(n), false);
                }
            }else{
                drawDisabledButton(sf::FloatRect(800, y, 300, 50), "Main screen", 30);
            }
            drawText(sf::FloatRect(800, y, 280, 50), string(main_count), AlignRight, 30, sf::Color::Black);
            y += 50;
        }

        for(int n=crew_pos_min; n<=crew_pos_max; n++)
        {
            if (drawToggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->crew_position[n], getCrewPositionName(ECrewPosition(n))))
            {
                bool active = !my_player_info->crew_position[n];
                my_player_info->setCrewPosition(ECrewPosition(n), active);
            }
            int cnt = 0;
            foreach(PlayerInfo, i, player_info_list)
                if (i->ship_id == my_ship_id && i->crew_position[n])
                    cnt++;
            drawText(sf::FloatRect(800, y, 280, 50), string(cnt), AlignRight, 30, sf::Color::Black);
            y += 50;
        }
        y += 25;
        if (!my_player_info->isMainScreen())
        {
            if (drawToggleButton(sf::FloatRect(800, y, 300, 50), my_player_info->main_screen_control, "Main screen ctrl"))
                my_player_info->setMainScreenControl(!my_player_info->main_screen_control);
        }else{
            drawDisabledButton(sf::FloatRect(800, y, 300, 50), "Main screen ctrl");
        }
        drawText(sf::FloatRect(800, y, 280, 50), string(main_screen_control_count), AlignRight, 30, sf::Color::Black);

        if (!my_player_info->isMainScreen() || (canDoMainScreen() && main_screen_option))
        {
            if (drawButton(sf::FloatRect(800, 600, 300, 50), "Ready"))
            {
                destroy();
                my_player_info->spawnUI();
            }
        }
    }else{
        drawText(sf::FloatRect(800, 100, 300, 50), "Select a ship", AlignCenter, 30);
    }
}
*/
