#ifndef GAME_MASTER_SCREEN_H
#define GAME_MASTER_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"

class GuiGlobalMessageEntry;
class GuiObjectCreationScreen;
class GuiObjectTweak;
class GuiRadarView;
class GuiOverlay;
class GuiSelector;
class GuiAutoLayout;
class GuiKeyValueDisplay;
class GuiListbox;
class GuiButton;
class GuiToggleButton;
class GuiTextEntry;
class GameMasterChatDialog;
class GuiObjectCreationView;
class GuiGlobalMessageEntryView;
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
    GuiGlobalMessageEntryView* global_message_entry;
    GuiObjectCreationView* object_creation_view;
    GuiObjectTweak* player_tweak_dialog;
    GuiObjectTweak* ship_tweak_dialog;
    GuiObjectTweak* object_tweak_dialog;

    bool position_text_custom;
    GuiTextEntry* position_text;
    GuiAutoLayout* info_layout;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiListbox* gm_script_options;
    GuiAutoLayout* order_layout;
    GuiButton* player_comms_hail;
    GuiButton* global_message_button;
    GuiToggleButton* pause_button;
    GuiToggleButton* intercept_comms_button;
    GuiButton* tweak_button;
    GuiButton* copy_scenario_button;
    GuiButton* copy_selected_button;
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
    const float max_distance = 10000000.0f;
    const float min_distance = 6250.0f;
public:
    GuiButton* create_button;
    GuiButton* cancel_create_button;

    GameMasterScreen();
    
    virtual void update(float delta);
    
    void onMouseDown(sf::Vector2f position);
    void onMouseDrag(sf::Vector2f position);
    void onMouseUp(sf::Vector2f position);

    virtual void onKey(sf::Event::KeyEvent key, int unicode);
    
    PVector<SpaceObject> getSelection();
    
    string getScriptExport(bool selected_only);
};


#endif//GAME_MASTER_SCREEN_H
