#include "main.h"
#include "gameGlobalInfo.h"
#include "gameMasterScreen.h"
#include "menus/shipSelectionScreen.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/spaceStation.h"

//TODO: ship retrofitting, idle/stand-ground/roaming/defend orders, GM to ship comms
GameMasterScreen::GameMasterScreen()
: click_and_drag_state(CD_None)
{
    main_radar = new GuiRadarView(this, "MAIN_RADAR", 50000.0f);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster();
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
        for(P<SpaceObject> obj : main_radar->getTargets())
        {
            if (obj)
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
    }))->setPosition(20, -90, ABottomLeft)->setSize(250, 50);
    cancel_create_button = new GuiButton(this, "CANCEL_CREATE_BUTTON", "Cancel", [this]() {
        cancel_create_button->hide();
    });
    cancel_create_button->setPosition(20, -90, ABottomLeft)->setSize(250, 50)->hide();
    
    info_layout = new GuiAutoLayout(this, "INFO_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    info_layout->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    global_message_entry = new GuiGlobalMessageEntry(this);
    global_message_entry->hide();
    object_creation_screen = new GuiObjectCreationScreen(this, this);
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
    
    std::unordered_map<string, string> selection_info;
    for(P<SpaceObject> obj : main_radar->getTargets())
    {
        if (!obj)
            continue;
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
        click_and_drag_state = CD_DragView;
    }
    else
    {
        if (cancel_create_button->isVisible())
        {
            object_creation_screen->createObject(position);
        }else{
            click_and_drag_state = CD_BoxSelect;
            
            float min_drag_distance = main_radar->getDistance() / 450 * 10;
            
            for(P<SpaceObject> obj : main_radar->getTargets())
            {
                if (obj)
                {
                    if ((obj->getPosition() - position) < std::max(min_drag_distance, obj->getRadius()))
                        click_and_drag_state = CD_DragObjects;
                }
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
    case CD_DragView:
        main_radar->setViewPosition(main_radar->getViewPosition() - (position - drag_previous_position));
        position -= (position - drag_previous_position);
        break;
    case CD_DragObjects:
        for(P<SpaceObject> obj : main_radar->getTargets())
        {
            if (obj)
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
    case CD_DragView:
        if (position - drag_start_position < 1.0f)
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
            for(P<SpaceObject> obj : main_radar->getTargets())
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

            for(P<SpaceObject> obj : main_radar->getTargets())
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
            main_radar->clearTargets();
            main_radar->setTargets(space_objects);
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
        for(P<SpaceObject> obj : main_radar->getTargets())
        {
            if (!obj)
                continue;
            
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

GuiObjectCreationScreen::GuiObjectCreationScreen(GuiContainer* owner, GameMasterScreen* gm_screen)
: GuiOverlay(owner, "OBJECT_CREATE_SCREEN", sf::Color(0, 0, 0, 128))
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
