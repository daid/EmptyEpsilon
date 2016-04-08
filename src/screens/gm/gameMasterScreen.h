#ifndef GAME_MASTER_SCREEN_H
#define GAME_MASTER_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/radarView.h"

class GuiGlobalMessageEntry;
class GuiObjectCreationScreen;
class GuiShipTweak;
class GameMasterScreen : public GuiCanvas, public Updatable
{
private:
    TargetsContainer targets;
    GuiRadarView* main_radar;
    GuiOverlay* box_selection_overlay;
    GuiSelector* faction_selector;
    
    GuiElement* chat_layer;
    GuiGlobalMessageEntry* global_message_entry;
    GuiObjectCreationScreen* object_creation_screen;
    GuiShipTweak* ship_tweak_dialog;
    
    GuiAutoLayout* info_layout;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiListbox* gm_script_options;
    GuiAutoLayout* order_layout;
    GuiButton* player_comms_hail;
    GuiButton* ship_tweak_button;
    
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
    GuiButton* create_button;
    GuiButton* cancel_create_button;

    GameMasterScreen();
    
    virtual void update(float delta);
    
    void onMouseDown(sf::Vector2f position);
    void onMouseDrag(sf::Vector2f position);
    void onMouseUp(sf::Vector2f position);

    virtual void onKey(sf::Keyboard::Key key, int unicode);
    
    string getScriptExport();
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
    GameMasterScreen* gm_screen;
public:
    GuiObjectCreationScreen(GameMasterScreen* gm_screen);
    
    virtual bool onMouseDown(sf::Vector2f position);
    
    void setCreateScript(string script);
    
    void createObject(sf::Vector2f position);
};

#endif//GAME_MASTER_SCREEN_H
