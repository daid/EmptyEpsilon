#ifndef GAME_MASTER_SCREEN_H
#define GAME_MASTER_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"

class GuiGlobalMessageEntry;
class GuiObjectCreationScreen;
class GuiShipTweak;
class GuiRadarView;
class GuiOverlay;
class GuiSelector;
class GuiAutoLayout;
class GuiKeyValueDisplay;
class GuiListbox;
class GuiButton;
class GuiTextEntry;
class GameMasterChatDialog;

class GameMasterScreen : public GuiCanvas, public Updatable
{
private:
    TargetsContainer targets;
    P<SpaceObject> target;
    GuiRadarView* main_radar;
    GuiOverlay* box_selection_overlay;
    GuiSelector* faction_selector;
    
    GuiElement* chat_layer;
    std::vector<GameMasterChatDialog*> chat_dialog_per_ship;
    GuiGlobalMessageEntry* global_message_entry;
    GuiObjectCreationScreen* object_creation_screen;
    GuiShipTweak* ship_tweak_dialog;
    
    GuiAutoLayout* info_layout;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiListbox* gm_script_options;
    GuiAutoLayout* order_layout;
    GuiButton* player_comms_hail;
    GuiButton* ship_tweak_button;
    GuiButton* export_button;
    GuiSelector* player_ship_selector;
    
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
    
    PVector<SpaceObject> getSelection();
    
    string getScriptExport(bool selected_only);
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
