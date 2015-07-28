#include "main.h"
#include "gameGlobalInfo.h"
#include "gameMasterScreen.h"
#include "menus/shipSelectionScreen.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/spaceStation.h"

GameMasterScreen::GameMasterScreen()
: click_and_drag_state(CD_None)
{
    main_radar = new GuiRadarView(this, "MAIN_RADAR", 50000.0f, &targets);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster()->enableTargetProjections();
    main_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    main_radar->setCallbacks(
        [this](sf::Vector2f position) { this->onMouseDown(position); },
        [this](sf::Vector2f position) { this->onMouseDrag(position); },
        [this](sf::Vector2f position) { this->onMouseUp(position); }
    );
    box_selection_overlay = new GuiOverlay(main_radar, "BOX_SELECTION", sf::Color(255, 255, 255, 32));
    box_selection_overlay->hide();
    
    (new GuiToggleButton(this, "PAUSE_BUTTON", "Pause", [this](bool value) {
        if (value)
            engine->setGameSpeed(1.0f);
        else
            engine->setGameSpeed(0.0f);
    }))->setPosition(20, 20, ATopLeft)->setSize(250, 50);
    
    faction_selector = new GuiSelector(this, "FACTION_SELECTOR", [this](int index, string value) {
        for(P<SpaceObject> obj : targets.getTargets())
        {
            obj->setFactionId(index);
        }
    });
    for(P<FactionInfo> info : factionInfo)
        faction_selector->addEntry(info->getName(), info->getName());
    faction_selector->setPosition(20, 70, ATopLeft)->setSize(250, 50);
    
    (new GuiButton(this, "GLOBAL_MESSAGE_BUTTON", "Global message", [this]() {
        global_message_entry->show();
    }))->setPosition(20, -20, ABottomLeft)->setSize(250, 50);

    (new GuiButton(this, "CREATE_OBJECT_BUTTON", "Create...", [this]() {
        object_creation_screen->show();
        cancel_create_button->show();
    }))->setPosition(20, -70, ABottomLeft)->setSize(250, 50);
    cancel_create_button = new GuiButton(this, "CANCEL_CREATE_BUTTON", "Cancel", [this]() {
        cancel_create_button->hide();
    });
    cancel_create_button->setPosition(20, -70, ABottomLeft)->setSize(250, 50)->hide();

    ship_retrofit_button = new GuiButton(this, "RETROFIT_SHIP", "Retrofit", [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
        {
            if (P<SpaceShip>(obj))
            {
                ship_retrofit_dialog->open(obj);
                break;
            }
        }
    });
    ship_retrofit_button->setPosition(20, -120, ABottomLeft)->setSize(250, 50)->hide();
    player_comms_hail = new GuiButton(this, "HAIL_PLAYER", "Hail ship", [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<PlayerSpaceship>(obj))
                hail_player_dialog->player = obj;
        if (hail_player_dialog->player)
            hail_player_dialog->show();
    });
    player_comms_hail->setPosition(20, -170, ABottomLeft)->setSize(250, 50)->hide();
    
    info_layout = new GuiAutoLayout(this, "INFO_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    info_layout->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);
    
    order_layout = new GuiAutoLayout(this, "ORDER_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    order_layout->setPosition(20, 130, ATopLeft)->setSize(250, GuiElement::GuiSizeMax);

    (new GuiLabel(order_layout, "ORDERS_LABEL", "Orders:", 20))->addBox()->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_IDLE", "Idle", [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderIdle();
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_ROAMING", "Roaming", [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderRoaming();
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_STAND_GROUND", "Stand Ground", [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderStandGround();
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_DEFEND_LOCATION", "Defend location", [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderDefendLocation(obj->getPosition());
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);

    hail_player_dialog = new GuiHailPlayerShip(this);
    hail_player_dialog->hide();
    hailing_player_dialog = new GuiHailingPlayerShip(this);
    hailing_player_dialog->hide();
    player_chat = new GuiPlayerChat(this);
    player_chat->hide();
    ship_retrofit_dialog = new GuiShipRetrofit(this);
    ship_retrofit_dialog->hide();

    global_message_entry = new GuiGlobalMessageEntry(this);
    global_message_entry->hide();
    object_creation_screen = new GuiObjectCreationScreen(this);
    object_creation_screen->hide();
}

void GameMasterScreen::update(float delta)
{
    float mouse_wheel_delta = InputHandler::getMouseWheelDelta();
    if (mouse_wheel_delta != 0.0)
    {
        float view_distance = main_radar->getDistance() * (1.0 - (mouse_wheel_delta * 0.1f));
        if (view_distance > 100000)
            view_distance = 100000;
        if (view_distance < 5000)
            view_distance = 5000;
        main_radar->setDistance(view_distance);
        if (view_distance < 10000)
            main_radar->shortRange();
        else
            main_radar->longRange();
    }
    
    bool has_ship = false;
    bool has_cpu_ship = false;
    bool has_player_ship = false;
    for(P<SpaceObject> obj : targets.getTargets())
    {
        if (P<SpaceShip>(obj))
        {
            has_ship = true;
            if (P<CpuShip>(obj))
                has_cpu_ship = true;
            else if (P<PlayerSpaceship>(obj))
                has_player_ship = true;
        }
    }
    ship_retrofit_button->setVisible(has_ship);
    order_layout->setVisible(has_cpu_ship);
    player_comms_hail->setVisible(has_player_ship);
    
    std::unordered_map<string, string> selection_info;
    for(P<SpaceObject> obj : targets.getTargets())
    {
        std::unordered_map<string, string> info = obj->getGMInfo();
        for(std::unordered_map<string, string>::iterator i = info.begin(); i != info.end(); i++)
        {
            if (selection_info.find(i->first) == selection_info.end())
            {
                selection_info[i->first] = i->second;
            }
            else if (selection_info[i->first] != i->second)
            {
                selection_info[i->first] = "*mixed*";
            }
        }
    }
    unsigned int cnt = 0;
    for(std::unordered_map<string, string>::iterator i = selection_info.begin(); i != selection_info.end(); i++)
    {
        if (cnt == info_items.size())
        {
            info_items.push_back(new GuiKeyValueDisplay(info_layout, "INFO_" + string(cnt), 0.5, i->first, i->second));
            info_items[cnt]->setSize(GuiElement::GuiSizeMax, 30);
        }else{
            info_items[cnt]->show();
            info_items[cnt]->setKey(i->first)->setValue(i->second);
        }
        cnt++;
    }
    while(cnt < info_items.size())
    {
        info_items[cnt]->hide();
        cnt++;
    }
}

void GameMasterScreen::onMouseDown(sf::Vector2f position)
{
    if (click_and_drag_state != CD_None)
        return;
    if (InputHandler::mouseIsDown(sf::Mouse::Right))
    {
        click_and_drag_state = CD_DragViewOrOrder;
    }
    else
    {
        if (cancel_create_button->isVisible())
        {
            object_creation_screen->createObject(position);
        }else{
            click_and_drag_state = CD_BoxSelect;
            
            float min_drag_distance = main_radar->getDistance() / 450 * 10;
            
            for(P<SpaceObject> obj : targets.getTargets())
            {
                if ((obj->getPosition() - position) < std::max(min_drag_distance, obj->getRadius()))
                    click_and_drag_state = CD_DragObjects;
            }
        }
    }
    drag_start_position = position;
    drag_previous_position = position;
}

void GameMasterScreen::onMouseDrag(sf::Vector2f position)
{
    switch(click_and_drag_state)
    {
    case CD_DragViewOrOrder:
    case CD_DragView:
        click_and_drag_state = CD_DragView;
        main_radar->setViewPosition(main_radar->getViewPosition() - (position - drag_previous_position));
        position -= (position - drag_previous_position);
        break;
    case CD_DragObjects:
        for(P<SpaceObject> obj : targets.getTargets())
        {
            obj->setPosition(obj->getPosition() + (position - drag_previous_position));
        }
        break;
    case CD_BoxSelect:
        box_selection_overlay->show();
        box_selection_overlay->setPosition(main_radar->worldToScreen(drag_start_position), ATopLeft);
        box_selection_overlay->setSize(main_radar->worldToScreen(position) - main_radar->worldToScreen(drag_start_position));
        break;
    default:
        break;
    }
    drag_previous_position = position;
}

void GameMasterScreen::onMouseUp(sf::Vector2f position)
{
    switch(click_and_drag_state)
    {
    case CD_DragViewOrOrder:
        {
            //Right click
            bool shift_down = InputHandler::keyboardIsDown(sf::Keyboard::LShift) || InputHandler::keyboardIsDown(sf::Keyboard::RShift);
            P<SpaceObject> target;
            PVector<Collisionable> list = CollisionManager::queryArea(position, position);
            foreach(Collisionable, collisionable, list)
            {
                P<SpaceObject> space_object = collisionable;
                if (space_object)
                {
                    if (!target || sf::length(position - space_object->getPosition()) < sf::length(position - target->getPosition()))
                        target = space_object;
                }
            }

            sf::Vector2f upper_bound(-std::numeric_limits<float>::max(), -std::numeric_limits<float>::max());
            sf::Vector2f lower_bound(std::numeric_limits<float>::max(), std::numeric_limits<float>::max());
            for(P<SpaceObject> obj : targets.getTargets())
            {
                P<CpuShip> cpu_ship = obj;
                if (!cpu_ship)
                    continue;
                
                lower_bound.x = std::min(lower_bound.x, obj->getPosition().x);
                lower_bound.y = std::min(lower_bound.y, obj->getPosition().y);
                upper_bound.x = std::max(upper_bound.x, obj->getPosition().x);
                upper_bound.y = std::max(upper_bound.y, obj->getPosition().y);
            }
            sf::Vector2f objects_center = (upper_bound + lower_bound) / 2.0f;

            for(P<SpaceObject> obj : targets.getTargets())
            {
                P<CpuShip> cpu_ship = obj;
                if (!cpu_ship)
                    continue;
                
                if (target && target != obj && target->canBeTargeted())
                {
                    if (obj->isEnemy(target))
                    {
                        cpu_ship->orderAttack(target);
                    }else{
                        if (!shift_down && target->canBeDockedBy(cpu_ship))
                            cpu_ship->orderDock(target);
                        else
                            cpu_ship->orderDefendTarget(target);
                    }
                }else{
                    if (shift_down)
                        cpu_ship->orderFlyTowardsBlind(position + (obj->getPosition() - objects_center));
                    else
                        cpu_ship->orderFlyTowards(position + (obj->getPosition() - objects_center));
                }
            }
        }
        break;
    case CD_BoxSelect:
        {
            PVector<Collisionable> objects = CollisionManager::queryArea(drag_start_position, position);
            PVector<SpaceObject> space_objects;
            foreach(Collisionable, c, objects)
            {
                space_objects.push_back(c);
            }
            targets.set(space_objects);
            if (space_objects.size() > 0)
                faction_selector->setSelectionIndex(space_objects[0]->getFactionId());
        }
        break;
    default:
        break;
    }
    click_and_drag_state = CD_None;
    box_selection_overlay->hide();
}

void GameMasterScreen::onKey(sf::Keyboard::Key key, int unicode)
{
    switch(key)
    {
    case sf::Keyboard::Delete:
        for(P<SpaceObject> obj : targets.getTargets())
        {
            obj->destroy();
        }
        break;

    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        new ShipSelectionScreen();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}

GuiGlobalMessageEntry::GuiGlobalMessageEntry(GuiContainer* owner)
: GuiOverlay(owner, "GLOBAL_MESSAGE_ENTRY", sf::Color(0, 0, 0, 128))
{
    GuiBox* box = new GuiBox(this, "FRAME");
    box->fill()->setPosition(0, 0, ACenter)->setSize(800, 150);
    
    message_entry = new GuiTextEntry(box, "MESSAGE_ENTRY", "");
    message_entry->setPosition(0, 20, ATopCenter)->setSize(700, 50);
    
    (new GuiButton(box, "CLOSE_BUTTON", "Cancel", [this]() {
        this->hide();
    }))->setPosition(20, -20, ABottomLeft)->setSize(300, 50);

    (new GuiButton(box, "SEND_BUTTON", "Send", [this]() {
        string message = message_entry->getText();
        if (message.length() > 0)
        {
            gameGlobalInfo->global_message = message;
            gameGlobalInfo->global_message_timeout = 5.0;
        }
        this->hide();
    }))->setPosition(-20, -20, ABottomRight)->setSize(300, 50);
}

bool GuiGlobalMessageEntry::onMouseDown(sf::Vector2f position)
{   //Catch clicks.
    return true;
}

GuiObjectCreationScreen::GuiObjectCreationScreen(GameMasterScreen* gm_screen)
: GuiOverlay(gm_screen, "OBJECT_CREATE_SCREEN", sf::Color(0, 0, 0, 128))
{
    GuiBox* box = new GuiBox(this, "FRAME");
    box->fill()->setPosition(0, 0, ACenter)->setSize(1000, 500);

    faction_selector = new GuiSelector(box, "FACTION_SELECTOR", nullptr);
    for(P<FactionInfo> info : factionInfo)
        faction_selector->addEntry(info->getName(), info->getName());
    faction_selector->setSelectionIndex(0);
    faction_selector->setPosition(20, 20, ATopLeft)->setSize(300, 50);
    
    float y = 20;
    std::vector<string> template_names = ShipTemplate::getStationTemplateNameList();
    std::sort(template_names.begin(), template_names.end());
    for(string template_name : template_names)
    {
        (new GuiButton(box, "CREATE_STATION_" + template_name, template_name, [this, template_name]() {
            create_script = "SpaceStation():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setTemplate(\"" + template_name + "\")";
            this->hide();
        }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
        y += 30;
    }
    
    (new GuiButton(box, "CREATE_WARP_JAMMER", "Warp Jammer", [this]() {
        create_script = "WarpJammer():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + ")";
        this->hide();
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_MINE", "Mine", [this]() {
        create_script = "Mine():setFactionId(" + string(faction_selector->getSelectionIndex()) + ")";
        this->hide();
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_BLACKHOLE", "BlackHole", [this]() {
        create_script = "BlackHole()";
        this->hide();
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    (new GuiButton(box, "CREATE_NEBULA", "Nebula", [this]() {
        create_script = "Nebula()";
        this->hide();
    }))->setTextSize(20)->setPosition(-350, y, ATopRight)->setSize(300, 30);
    y += 30;
    
    y = 20;
    template_names = ShipTemplate::getTemplateNameList();
    std::sort(template_names.begin(), template_names.end());
    for(string template_name : template_names)
    {
        (new GuiButton(box, "CREATE_SHIP_" + template_name, template_name, [this, template_name]() {
            create_script = "CpuShip():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setShipTemplate(\"" + template_name + "\"):orderRoaming()";
            this->hide();
        }))->setTextSize(20)->setPosition(-20, y, ATopRight)->setSize(300, 30);
        y += 30;
    }
    
    (new GuiButton(box, "CLOSE_BUTTON", "Cancel", [this, gm_screen]() {
        create_script = "";
        gm_screen->cancel_create_button->hide();
        this->hide();
    }))->setPosition(20, -20, ABottomLeft)->setSize(300, 50);
}

bool GuiObjectCreationScreen::onMouseDown(sf::Vector2f position)
{   //Catch clicks.
    return true;
}

void GuiObjectCreationScreen::createObject(sf::Vector2f position)
{
    if (create_script == "")
        return;
    
    P<ScriptObject> so = new ScriptObject();
    so->runCode(create_script + ":setPosition("+string(position.x)+","+string(position.y)+")");
    so->destroy();
}

GuiHailPlayerShip::GuiHailPlayerShip(GameMasterScreen* owner)
: GuiBox(owner, "HAIL_PLAYER_SHIP_DIALOG")
{
    setPosition(0, -100, ABottomCenter);
    setSize(600, 150);
    fill();

    caller_entry = new GuiTextEntry(this, "MESSAGE_ENTRY", "Main Command");
    caller_entry->setPosition(0, 20, ATopCenter)->setSize(500, 50);
    
    (new GuiButton(this, "CLOSE_BUTTON", "Cancel", [this]() {
        this->hide();
    }))->setPosition(20, -20, ABottomLeft)->setSize(250, 50);

    (new GuiButton(this, "SEND_BUTTON", "Call", [this, owner]() {
        if (player)
        {
            if (player->comms_state == CS_Inactive || player->comms_state == CS_ChannelFailed || player->comms_state == CS_ChannelBroken)
            {
                player->comms_state = CS_BeingHailedByGM;
                player->comms_target_name = caller_entry->getText();
                owner->hailing_player_dialog->player = player;
                owner->hailing_player_dialog->show();
            }
        }
        this->hide();
    }))->setPosition(-20, -20, ABottomRight)->setSize(250, 50);
}

bool GuiHailPlayerShip::onMouseDown(sf::Vector2f position)
{   //Catch clicks.
    return true;
}

GuiHailingPlayerShip::GuiHailingPlayerShip(GameMasterScreen* owner)
: GuiBox(owner, "HAILING_PLAYER_SHIP_DIALOG"), owner(owner)
{
    setPosition(0, -100, ABottomCenter);
    setSize(600, 90);
    fill();

    (new GuiLabel(this, "HAILING_LABEL", "Hailing ship...", 30))->setPosition(0, 0, ACenter)->setSize(500, 50);
}

bool GuiHailingPlayerShip::onMouseDown(sf::Vector2f position)
{   //Catch clicks.
    return true;
}

void GuiHailingPlayerShip::onDraw(sf::RenderTarget& window)
{
    if (!player)
    {
        hide();
        return;
    }
    switch(player->comms_state)
    {
    case CS_Inactive:
    case CS_ChannelFailed:
    case CS_ChannelBroken:
    case CS_OpeningChannel:
    case CS_BeingHailed:
    case CS_ChannelOpen:
    case CS_ChannelOpenPlayer:
        hide();
        break;
    case CS_BeingHailedByGM:
        break;
    case CS_ChannelOpenGM:
        owner->player_chat->player = player;
        owner->player_chat->show();
        hide();
        break;
    }
    GuiBox::onDraw(window);
}

GuiPlayerChat::GuiPlayerChat(GameMasterScreen* owner)
: GuiBox(owner, "PLAYER_CHAT_DIALOG")
{
    setPosition(0, -100, ABottomCenter);
    setSize(800, 600);
    fill();

    message_entry = new GuiTextEntry(this, "MESSAGE_ENTRY", "");
    message_entry->setPosition(20, -20, ABottomLeft)->setSize(640, 50);
    message_entry->enterCallback([this](string text){
        if (player)
        {
            player->comms_incomming_message = player->comms_incomming_message + "\n>" + message_entry->getText();
        }
        message_entry->setText("");
    });
    
    chat_text = new GuiScrollText(this, "CHAT_TEXT", "");
    chat_text->enableAutoScrollDown()->setPosition(20, 30, ATopLeft)->setSize(760, 500);
    
    (new GuiButton(this, "SEND_BUTTON", "Send", [this]() {
        if (player)
        {
            player->comms_incomming_message = player->comms_incomming_message + "\n>" + message_entry->getText();
        }
        message_entry->setText("");
    }))->setPosition(-20, -20, ABottomRight)->setSize(120, 50);

    (new GuiButton(this, "CLOSE_BUTTON", "Close", [this]() {
        hide();
        if (player)
            player->comms_state = CS_Inactive;
    }))->setTextSize(20)->setPosition(-10, 0, ATopRight)->setSize(70, 30);
}

bool GuiPlayerChat::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiPlayerChat::onDraw(sf::RenderTarget& window)
{
    if (!player || player->comms_state != CS_ChannelOpenGM)
    {
        hide();
        return;
    }
    chat_text->setText(player->comms_incomming_message);
    
    GuiBox::onDraw(window);
}

GuiShipRetrofit::GuiShipRetrofit(GuiContainer* owner)
: GuiBox(owner, "SHIP_RETROFIT_DIALOG")
{
    setPosition(0, -100, ABottomCenter);
    setSize(800, 600);
    fill();
    
    GuiAutoLayout* left_col = new GuiAutoLayout(this, "LEFT_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_col->setPosition(20, 20, ATopLeft)->setSize(300, 600);
    
    type_name = new GuiTextEntry(left_col, "TYPE_NAME", "???");
    type_name->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    type_name->callback([this](string text) {
        target->ship_type_name = text;
    });
    
    warp_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->setWarpDrive(index != 0);
    });
    warp_selector->setTextSize(20)->setOptions({"WarpDrive: No", "WarpDrive: Yes"})->setSize(GuiElement::GuiSizeMax, 30);
    jump_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->setJumpDrive(index != 0);
    });
    jump_selector->setTextSize(20)->setOptions({"JumpDrive: No", "JumpDrive: Yes"})->setSize(GuiElement::GuiSizeMax, 30);
    
    (new GuiLabel(left_col, "", "Impulse speed:", 30))->setSize(GuiElement::GuiSizeMax, 30);
    impulse_speed_slider = new GuiSlider(left_col, "", 0.0, 250, 0.0, [this](float value) {
        target->impulse_max_speed = value;
    });
    impulse_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    
    (new GuiLabel(left_col, "", "Turn speed:", 30))->setSize(GuiElement::GuiSizeMax, 30);
    turn_speed_slider = new GuiSlider(left_col, "", 0.0, 25, 0.0, [this](float value) {
        target->turn_speed = value;
    });
    turn_speed_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    
    (new GuiLabel(left_col, "", "Hull:", 30))->setSize(GuiElement::GuiSizeMax, 30);
    hull_slider = new GuiSlider(left_col, "", 0.0, 500, 0.0, [this](float value) {
        target->hull_max = value;
        target->hull_strength = std::min(target->hull_strength, target->hull_max);
    });
    hull_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(left_col, "", "Front shield:", 30))->setSize(GuiElement::GuiSizeMax, 30);
    front_shield_slider = new GuiSlider(left_col, "", 0.0, 500, 0.0, [this](float value) {
        target->front_shield_max = value;
        target->front_shield = std::min(target->front_shield, target->front_shield_max);
    });
    front_shield_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);

    (new GuiLabel(left_col, "", "Rear shield:", 30))->setSize(GuiElement::GuiSizeMax, 30);
    rear_shield_slider = new GuiSlider(left_col, "", 0.0, 500, 0.0, [this](float value) {
        target->rear_shield_max = value;
        target->rear_shield = std::min(target->rear_shield, target->rear_shield_max);
    });
    rear_shield_slider->addOverlay()->setSize(GuiElement::GuiSizeMax, 30);
    
    missile_tube_amount_selector = new GuiSelector(left_col, "", [this](int index, string value) {
        target->weapon_tubes = index;
    });
    for(int n=0; n<max_weapon_tubes; n++)
        missile_tube_amount_selector->addEntry("Missile tubes: " + string(n), "");
    missile_tube_amount_selector->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    
    for(int n=0; n<MW_Count; n++)
    {
        missile_storage_amount_selector[n] = new GuiSelector(left_col, "", [this, n](int index, string value) {
            int diff = target->weapon_storage_max[n] - index;
            target->weapon_storage_max[n] += diff;
            target->weapon_storage[n] = std::max(0, target->weapon_storage[n] + diff);
        });
        for(int m=0; m<50; m++)
            missile_storage_amount_selector[n]->addEntry(getMissileWeaponName(EMissileWeapons(n)) + ": " + string(m), "");
        missile_storage_amount_selector[n]->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    }
/*
    x += 350;
    y = 200;
    for(int n=0; n<SYS_COUNT; n++)
    {
        ESystem system = ESystem(n);
        if (ship->hasSystem(system))
        {
            int diff = drawSelector(sf::FloatRect(x, y, 300, 30), getSystemName(system) + ": " + string(ship->systems[n].health * 100) + "%", 20);
            y += 30;
            ship->systems[n].health = std::min(1.0f, std::max(-1.0f, ship->systems[n].health + diff * 0.10f));
        }
    }
*/

    (new GuiButton(this, "CLOSE_BUTTON", "Close", [this]() {
        hide();
    }))->setTextSize(20)->setPosition(-10, 0, ATopRight)->setSize(70, 30);
}

bool GuiShipRetrofit::onMouseDown(sf::Vector2f position)
{
    return true;
}

void GuiShipRetrofit::open(P<SpaceShip> target)
{
    this->target = target;
    
    type_name->setText(target->ship_type_name);
    warp_selector->setSelectionIndex(target->has_warp_drive ? 1 : 0);
    jump_selector->setSelectionIndex(target->hasJumpDrive() ? 1 : 0);
    impulse_speed_slider->setValue(target->impulse_max_speed);
    impulse_speed_slider->setSnapValue(target->ship_template->impulse_speed, 5.0f);
    turn_speed_slider->setValue(target->turn_speed);
    turn_speed_slider->setSnapValue(target->ship_template->turn_speed, 1.0f);
    hull_slider->setValue(target->hull_max);
    hull_slider->setSnapValue(target->ship_template->hull, 5.0f);
    front_shield_slider->setValue(target->front_shield_max);
    front_shield_slider->setSnapValue(target->ship_template->front_shields, 5.0f);
    rear_shield_slider->setValue(target->rear_shield_max);
    rear_shield_slider->setSnapValue(target->ship_template->rear_shields, 5.0f);
    missile_tube_amount_selector->setSelectionIndex(target->weapon_tubes);
    for(int n=0; n<MW_Count; n++)
        missile_storage_amount_selector[n]->setSelectionIndex(target->weapon_storage_max[n]);
    
    show();
}
