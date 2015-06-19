#ifndef GAME_MASTER_SCREEN_H
#define GAME_MASTER_SCREEN_H

#include "engine.h"
#include "gui/gui2.h"
#include "screenComponents/radarView.h"

class GuiGlobalMessageEntry;
class GuiObjectCreationScreen;
class GameMasterScreen : public GuiCanvas, public Updatable
{
private:
    GuiRadarView* main_radar;
    GuiOverlay* box_selection_overlay;
    GuiSelector* faction_selector;
    GuiGlobalMessageEntry* global_message_entry;
    GuiObjectCreationScreen* object_creation_screen;
    GuiAutoLayout* info_layout;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiAutoLayout* order_layout;
    
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
    GuiObjectCreationScreen(GuiContainer* owner, GameMasterScreen* gm_screen);
    
    virtual bool onMouseDown(sf::Vector2f position);
    
    void createObject(sf::Vector2f position);
};

#endif//GAME_MASTER_SCREEN_H
