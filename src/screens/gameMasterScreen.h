#ifndef GAME_MASTER_SCREEN_H
#define GAME_MASTER_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/radarView.h"

class GuiGlobalMessageEntry;
class GuiObjectCreationScreen;
class GuiHailPlayerShip;
class GuiHailingPlayerShip;
class GuiPlayerChat;
class GameMasterScreen : public GuiCanvas, public Updatable
{
private:
    GuiRadarView* main_radar;
    GuiOverlay* box_selection_overlay;
    GuiSelector* faction_selector;
    GuiGlobalMessageEntry* global_message_entry;
    GuiObjectCreationScreen* object_creation_screen;
    GuiHailPlayerShip* hail_player_dialog;
    GuiAutoLayout* info_layout;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiAutoLayout* order_layout;
    GuiButton* player_comms_hail;
    
    enum EClickAndDragState
    {
        CD_None,
        CD_DragViewOrOrder,
        CD_DragView,
        CD_BoxSelect,
        CD_DragObjects
    } click_and_drag_state;
    sf::Vector2f drag_start_position;
    sf::Vector2f drag_previous_position;
public:
    GuiButton* cancel_create_button;
    GuiHailingPlayerShip* hailing_player_dialog;
    GuiPlayerChat* player_chat;

    GameMasterScreen();
    
    virtual void update(float delta);
    
    void onMouseDown(sf::Vector2f position);
    void onMouseDrag(sf::Vector2f position);
    void onMouseUp(sf::Vector2f position);

    virtual void onKey(sf::Keyboard::Key key, int unicode);
};

class GuiGlobalMessageEntry : public GuiOverlay
{
private:
    GuiTextEntry* message_entry;
public:
    GuiGlobalMessageEntry(GuiContainer* owner);
    
    virtual bool onMouseDown(sf::Vector2f position);
};

class GuiObjectCreationScreen : public GuiOverlay
{
private:
    string create_script;
    GuiSelector* faction_selector;
public:
    GuiObjectCreationScreen(GameMasterScreen* gm_screen);
    
    virtual bool onMouseDown(sf::Vector2f position);
    
    void createObject(sf::Vector2f position);
};

class GuiHailPlayerShip : public GuiBox
{
private:
    GuiTextEntry* caller_entry;
public:
    P<PlayerSpaceship> player;

    GuiHailPlayerShip(GameMasterScreen* owner);
    
    virtual bool onMouseDown(sf::Vector2f position);
};

class GuiHailingPlayerShip : public GuiBox
{
private:
    GameMasterScreen* owner;
public:
    P<PlayerSpaceship> player;
    
    GuiHailingPlayerShip(GameMasterScreen* owner);
    
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onDraw(sf::RenderTarget& window);
};

class GuiPlayerChat : public GuiBox
{
private:
    GuiTextEntry* message_entry;
    GuiScrollText* chat_text;
public:
    P<PlayerSpaceship> player;
    
    GuiPlayerChat(GameMasterScreen* owner);
    
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GAME_MASTER_SCREEN_H
