#include "gameMasterScreen.h"
#include "shipTemplate.h"
#include "main.h"
#include "gameGlobalInfo.h"
#include "objectCreationView.h"
#include "globalMessageEntryView.h"
#include "tweak.h"
#include "chatDialog.h"
#include "spaceObjects/cpuShip.h"
#include "spaceObjects/spaceStation.h"
#include "spaceObjects/wormHole.h"
#include "spaceObjects/zone.h"

#include "screenComponents/radarView.h"

#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_label.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_textentry.h"

GameMasterScreen::GameMasterScreen()
: click_and_drag_state(CD_None)
{
    main_radar = new GuiRadarView(this, "MAIN_RADAR", 50000.0f, &targets);
    main_radar->setStyle(GuiRadarView::Rectangular)->longRange()->gameMaster()->enableTargetProjections(nullptr)->setAutoCentering(false);
    main_radar->setPosition(0, 0, ATopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    main_radar->setCallbacks(
        [this](glm::vec2 position) { this->onMouseDown(position); },
        [this](glm::vec2 position) { this->onMouseDrag(position); },
        [this](glm::vec2 position) { this->onMouseUp(position); }
    );
    box_selection_overlay = new GuiOverlay(main_radar, "BOX_SELECTION", sf::Color(255, 255, 255, 32));
    box_selection_overlay->hide();

    pause_button = new GuiToggleButton(this, "PAUSE_BUTTON", tr("button", "Pause"), [](bool value) {
        if (!value)
            engine->setGameSpeed(1.0f);
        else
            engine->setGameSpeed(0.0f);
    });
    pause_button->setValue(engine->getGameSpeed() == 0.0f)->setPosition(20, 20, ATopLeft)->setSize(250, 50);

    intercept_comms_button = new GuiToggleButton(this, "INTERCEPT_COMMS_BUTTON", tr("button", "Intercept all comms"), [](bool value) {
        gameGlobalInfo->intercept_all_comms_to_gm = value;
    });
    intercept_comms_button->setValue(gameGlobalInfo->intercept_all_comms_to_gm)->setTextSize(20)->setPosition(300, 20, ATopLeft)->setSize(200, 25);

    faction_selector = new GuiSelector(this, "FACTION_SELECTOR", [this](int index, string value) {
        for(P<SpaceObject> obj : targets.getTargets())
        {
            obj->setFactionId(index);
        }
    });
    for(P<FactionInfo> info : factionInfo)
        faction_selector->addEntry(info->getLocaleName(), info->getName());
    faction_selector->setPosition(20, 70, ATopLeft)->setSize(250, 50);

    global_message_button = new GuiButton(this, "GLOBAL_MESSAGE_BUTTON", tr("button", "Global message"), [this]() {
        global_message_entry->show();
    });
    global_message_button->setPosition(20, -20, ABottomLeft)->setSize(250, 50);

    player_ship_selector = new GuiSelector(this, "PLAYER_SHIP_SELECTOR", [this](int index, string value) {
        P<SpaceObject> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship)
            target = ship;
        main_radar->setViewPosition(ship->getPosition());
        targets.set(ship);
    });
    player_ship_selector->setPosition(270, -20, ABottomLeft)->setSize(350, 50);

    create_button = new GuiButton(this, "CREATE_OBJECT_BUTTON", tr("button", "Create..."), [this]() {
        object_creation_view->show();
    });
    create_button->setPosition(20, -70, ABottomLeft)->setSize(250, 50);

    copy_scenario_button = new GuiButton(this, "COPY_SCENARIO_BUTTON", tr("button", "Copy scenario"), [this]() {
        Clipboard::setClipboard(getScriptExport(false));
    });
    copy_scenario_button->setTextSize(20)->setPosition(-20, -20, ABottomRight)->setSize(125, 25);

    copy_selected_button = new GuiButton(this, "COPY_SELECTED_BUTTON", tr("button", "Copy selected"), [this]() {
        Clipboard::setClipboard(getScriptExport(true));
    });
    copy_selected_button->setTextSize(20)->setPosition(-20, -45, ABottomRight)->setSize(125, 25);

    cancel_action_button = new GuiButton(this, "CANCEL_CREATE_BUTTON", tr("button", "Cancel"), []() {
        gameGlobalInfo->on_gm_click = nullptr;
    });
    cancel_action_button->setPosition(20, -70, ABottomLeft)->setSize(250, 50)->hide();

    tweak_button = new GuiButton(this, "TWEAK_OBJECT", tr("button", "Tweak"), [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
        {
            if (P<PlayerSpaceship>(obj))
            {
                player_tweak_dialog->open(obj);
                break;
            }
            else if (P<SpaceShip>(obj))
            {
                ship_tweak_dialog->open(obj);
                break;
            }
            else if (P<SpaceStation>(obj))
            {
                station_tweak_dialog->open(obj);
            }
            else if (P<WarpJammer>(obj))
            {
                jammer_tweak_dialog->open(obj);
            }
            else if (P<Asteroid>(obj))
            {
                asteroid_tweak_dialog->open(obj);
            }
            else
            {
                object_tweak_dialog->open(obj);
                break;
            }
        }
    });
    tweak_button->setPosition(20, -120, ABottomLeft)->setSize(250, 50)->hide();

    player_comms_hail = new GuiButton(this, "HAIL_PLAYER", tr("button", "Hail ship"), [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
        {
            if (P<PlayerSpaceship>(obj))
            {
                int idx = gameGlobalInfo->findPlayerShip(obj);
                chat_dialog_per_ship[idx]->show()->setPosition(main_radar->worldToScreen(obj->getPosition()))->setSize(300, 300);
            }
        }
    });
    player_comms_hail->setPosition(20, -170, ABottomLeft)->setSize(250, 50)->hide();

    info_layout = new GuiAutoLayout(this, "INFO_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    info_layout->setPosition(-20, 20, ATopRight)->setSize(300, GuiElement::GuiSizeMax);

    info_clock = new GuiKeyValueDisplay(info_layout, "INFO_CLOCK", 0.5, tr("Clock"), "");
    info_clock->setSize(GuiElement::GuiSizeMax, 30);

    gm_script_options = new GuiListbox(this, "GM_SCRIPT_OPTIONS", [this](int index, string value)
    {
        gm_script_options->setSelectionIndex(-1);
        int n = 0;
        for(GMScriptCallback& callback : gameGlobalInfo->gm_callback_functions)
        {
            if (n == index)
            {
                callback.callback.call<void>();
                return;
            }
            n++;
        }
    });
    gm_script_options->setPosition(20, 130, ATopLeft)->setSize(250, 500);

    order_layout = new GuiAutoLayout(this, "ORDER_LAYOUT", GuiAutoLayout::LayoutVerticalBottomToTop);
    order_layout->setPosition(-20, -90, ABottomRight)->setSize(300, GuiElement::GuiSizeMax);

    (new GuiButton(order_layout, "ORDER_DEFEND_LOCATION", tr("Defend location"), [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderDefendLocation(obj->getPosition());
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_STAND_GROUND", tr("Stand ground"), [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderStandGround();
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_ROAMING", tr("Roaming"), [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderRoaming();
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiButton(order_layout, "ORDER_IDLE", tr("Idle"), [this]() {
        for(P<SpaceObject> obj : targets.getTargets())
            if (P<CpuShip>(obj))
                P<CpuShip>(obj)->orderIdle();
    }))->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 30);
    (new GuiLabel(order_layout, "ORDERS_LABEL", tr("Orders:"), 20))->addBackground()->setSize(GuiElement::GuiSizeMax, 30);

    chat_layer = new GuiElement(this, "");
    chat_layer->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        chat_dialog_per_ship.push_back(new GameMasterChatDialog(chat_layer, main_radar, n));
        chat_dialog_per_ship[n]->hide();
    }

    player_tweak_dialog = new GuiObjectTweak(this, TW_Player);
    player_tweak_dialog->hide();
    ship_tweak_dialog = new GuiObjectTweak(this, TW_Ship);
    ship_tweak_dialog->hide();
    object_tweak_dialog = new GuiObjectTweak(this, TW_Object);
    object_tweak_dialog->hide();
    station_tweak_dialog = new GuiObjectTweak(this, TW_Station);
    station_tweak_dialog->hide();
    jammer_tweak_dialog = new GuiObjectTweak(this, TW_Jammer);
    jammer_tweak_dialog->hide();
    asteroid_tweak_dialog = new GuiObjectTweak(this, TW_Asteroid);
    asteroid_tweak_dialog->hide();

    global_message_entry = new GuiGlobalMessageEntryView(this);
    global_message_entry->hide();
    object_creation_view = new GuiObjectCreationView(this);
    object_creation_view->hide();

    message_frame = new GuiPanel(this, "");
    message_frame->setPosition(0, 0, ATopCenter)->setSize(900, 230)->hide();

    message_text = new GuiScrollText(message_frame, "", "");
    message_text->setTextSize(20)->setPosition(20, 20, ATopLeft)->setSize(900 - 40, 200 - 40);
    message_close_button = new GuiButton(message_frame, "", tr("button", "Close"), []() {
        if (!gameGlobalInfo->gm_messages.empty())
        {
            gameGlobalInfo->gm_messages.pop_front();
        }

    });
    message_close_button->setTextSize(30)->setPosition(-20, -20, ABottomRight)->setSize(300, 30);
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
GameMasterScreen::~GameMasterScreen()
{
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

    bool has_object = false;
    bool has_cpu_ship = false;
    bool has_player_ship = false;

    // Add and remove entries from the player ship list.
    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (player_ship_selector->indexByValue(string(n)) == -1)
            {
                player_ship_selector->addEntry(ship->getTypeName() + " " + ship->getCallSign(), string(n));
            } else {
                player_ship_selector->setEntryName(player_ship_selector->indexByValue(string(n)),ship->getCallSign());
            }

            if (ship->isCommsBeingHailedByGM() || ship->isCommsChatOpenToGM())
            {
                if (!chat_dialog_per_ship[n]->isVisible())
                {
                    chat_dialog_per_ship[n]->show()->setPosition(main_radar->worldToScreen(ship->getPosition()))->setSize(300, 300);
                }
            }
        }else{
            if (player_ship_selector->indexByValue(string(n)) != -1)
                player_ship_selector->removeEntry(player_ship_selector->indexByValue(string(n)));
        }
    }

    // Record object type.
    for(P<SpaceObject> obj : targets.getTargets())
    {
        has_object = true;
        if (P<CpuShip>(obj))
            has_cpu_ship = true;
        else if (P<PlayerSpaceship>(obj))
            has_player_ship = true;
    }

    // Show player ship selector only if there are player ships.
    player_ship_selector->setVisible(player_ship_selector->entryCount() > 0);

    // Show tweak button.
    tweak_button->setVisible(has_object);

    order_layout->setVisible(has_cpu_ship);
    player_comms_hail->setVisible(has_player_ship);

    // Update mission clock
    info_clock->setValue(string(gameGlobalInfo->elapsed_time, 0));

    std::unordered_map<string, string> selection_info;

    // For each selected object, determine and report their type.
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
                selection_info[i->first] = tr("*mixed*");
            }
        }
    }

    if (targets.getTargets().size() == 1)
    {
        selection_info[trMark("gm_info", "Position")] = string(targets.getTargets()[0]->getPosition().x, 0) + "," + string(targets.getTargets()[0]->getPosition().y, 0);
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
            info_items[cnt]->setKey(tr("gm_info", i->first))->setValue(i->second);
        }
        cnt++;
    }
    while(cnt < info_items.size())
    {
        info_items[cnt]->hide();
        cnt++;
    }

    bool gm_functions_changed = gm_script_options->entryCount() != int(gameGlobalInfo->gm_callback_functions.size());
    auto it = gameGlobalInfo->gm_callback_functions.begin();
    for(int n=0; !gm_functions_changed && n<gm_script_options->entryCount(); n++)
    {
        if (gm_script_options->getEntryName(n) != it->name)
            gm_functions_changed = true;
        it++;
    }
    if (gm_functions_changed)
    {
        gm_script_options->setOptions({});
        for(const GMScriptCallback& callback : gameGlobalInfo->gm_callback_functions)
        {
            gm_script_options->addEntry(callback.name, callback.name);
        }
    }

    if (!gameGlobalInfo->gm_messages.empty())
    {
        GMMessage* message = &gameGlobalInfo->gm_messages.front();
        message_text->setText(message->text);
        message_frame->show();
    } else {
        message_frame->hide();
    }

    if (gameGlobalInfo->on_gm_click)
    {
        create_button->hide();
        object_creation_view->hide();
        cancel_action_button->show();
    }
    else
    {
        create_button->show();
        cancel_action_button->hide();
    }
}

void GameMasterScreen::onMouseDown(glm::vec2 position)
{
    if (click_and_drag_state != CD_None)
        return;
    if (InputHandler::mouseIsDown(sf::Mouse::Right))
    {
        click_and_drag_state = CD_DragViewOrOrder;
    }
    else
    {
        if (gameGlobalInfo->on_gm_click)
        {
            gameGlobalInfo->on_gm_click(position);
        }else{
            click_and_drag_state = CD_BoxSelect;

            float min_drag_distance = main_radar->getDistance() / 450 * 10;

            for(P<SpaceObject> obj : targets.getTargets())
            {
                if (glm::length(obj->getPosition() - position) < std::max(min_drag_distance, obj->getRadius()))
                    click_and_drag_state = CD_DragObjects;
            }
        }
    }
    drag_start_position = position;
    drag_previous_position = position;
}

void GameMasterScreen::onMouseDrag(glm::vec2 position)
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

void GameMasterScreen::onMouseUp(glm::vec2 position)
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
                    if (!target || glm::length(position - space_object->getPosition()) < glm::length(position - target->getPosition()))
                        target = space_object;
                }
            }

            glm::vec2 upper_bound(-std::numeric_limits<float>::max(), -std::numeric_limits<float>::max());
            glm::vec2 lower_bound(std::numeric_limits<float>::max(), std::numeric_limits<float>::max());
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
            glm::vec2 objects_center = (upper_bound + lower_bound) / 2.0f;

            for(P<SpaceObject> obj : targets.getTargets())
            {
                P<CpuShip> cpu_ship = obj;
                P<WormHole> wormhole = obj;
                if (cpu_ship)
                {
                    if (target && target != obj && target->canBeTargetedBy(obj))
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
                else if (wormhole)
                {
                    wormhole->setTargetPosition(position);
                }


            }
        }
        break;
    case CD_BoxSelect:
        {
            bool shift_down = InputHandler::keyboardIsDown(sf::Keyboard::LShift) || InputHandler::keyboardIsDown(sf::Keyboard::RShift);
            //Using sf::Keyboard::isKeyPressed, as CTRL does not seem to generate keydown/key up events in SFML.
            bool ctrl_down = sf::Keyboard::isKeyPressed(sf::Keyboard::LControl) || sf::Keyboard::isKeyPressed(sf::Keyboard::RControl);
            bool alt_down = InputHandler::keyboardIsDown(sf::Keyboard::LAlt) || InputHandler::keyboardIsDown(sf::Keyboard::RAlt);
            PVector<Collisionable> objects = CollisionManager::queryArea(drag_start_position, position);
            PVector<SpaceObject> space_objects;
            foreach(Collisionable, c, objects)
            {
                if (P<Zone>(c))
                    continue;
                if (ctrl_down && !P<ShipTemplateBasedObject>(c))
                    continue;
                if (alt_down && (!P<SpaceObject>(c) || (int)(P<SpaceObject>(c))->getFactionId() != faction_selector->getSelectionIndex()))
                    continue;
                space_objects.push_back(c);
            }
            if (shift_down)
            {
                foreach(SpaceObject, s, space_objects)
                {
                    targets.add(s);
                }
            } else {
                targets.set(space_objects);
            }


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

void GameMasterScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    case sf::Keyboard::Delete:
        for(P<SpaceObject> obj : targets.getTargets())
        {
            if (obj)
                obj->destroy();
        }
        break;
    case sf::Keyboard::F5:
        Clipboard::setClipboard(getScriptExport(false));
        break;

    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        returnToShipSelection();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}

PVector<SpaceObject> GameMasterScreen::getSelection()
{
    return targets.getTargets();
}

string GameMasterScreen::getScriptExport(bool selected_only)
{
    string output;
    PVector<SpaceObject> objs;
    if (selected_only)
    {
        objs = targets.getTargets();
    }else{
        objs = space_object_list;
    }

    foreach(SpaceObject, obj, objs)
    {
        string line = obj->getExportLine();
        if (line == "")
            continue;
        output += "    " + line + "\n";
    }
    return output;
}
