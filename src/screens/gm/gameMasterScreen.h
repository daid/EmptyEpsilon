#pragma once

#include "engine.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"
#include "Updatable.h"

class GuiGlobalMessageEntry;
class GuiObjectCreationScreen;
class GuiEntityTweak;
class GuiRadarView;
class GuiRadarZoomSlider;
class GuiOverlay;
class GuiSelector;
class GuiKeyValueDisplay;
class GuiListbox;
class GuiButton;
class GuiToggleButton;
class GuiTextEntry;
class GameMasterChatDialog;
class GuiObjectCreationView;
class GuiGlobalMessageEntryView;
class GuiHelpOverlay;
class GuiPanel;

class GameMasterScreen : public GuiCanvas, public Updatable
{
private:
    const float MIN_ZOOM_DISTANCE = 5000.0f;
    const float MAX_ZOOM_DISTANCE = 1000000.0f;
    const float LONG_RANGE_DISTANCE = 50000.0f;
    const float SHORT_RANGE_DISTANCE = 10000.0f;

    TargetsContainer targets;
    sp::ecs::Entity target;
    GuiRadarView* main_radar;
    GuiOverlay* box_selection_overlay;
    GuiSelector* faction_selector;

    GuiElement* chat_layer;
    std::vector<GameMasterChatDialog*> chat_dialog_per_ship;
    GuiGlobalMessageEntryView* global_message_entry;
    GuiObjectCreationView* object_creation_view;
    GuiEntityTweak* tweak_dialog;

    GuiElement* info_layout;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiKeyValueDisplay* info_clock;
    GuiListbox* gm_script_options;
    GuiElement* order_layout;
    GuiButton* player_comms_hail;
    GuiButton* global_message_button;
    GuiToggleButton* pause_button;
    GuiToggleButton* intercept_comms_button;
    GuiButton* tweak_button;
    GuiRadarZoomSlider* zoom_slider;
    GuiButton* copy_scenario_button;
    GuiButton* copy_selected_button;
    GuiSelector* player_ship_selector;

    GuiPanel* message_frame;
    GuiScrollText* message_text;
    GuiButton* message_close_button;

    GuiHelpOverlay* keyboard_help;

    enum class ClickAndDragState
    {
        None,
        DragViewOrOrder,
        DragView,
        ClickSelectOrBoxSelect,
        BoxSelect,
        ClickSelectOrDragObjects,
        DragObjects,
        CreateWithDrag
    } click_and_drag_state = ClickAndDragState::None;

    glm::vec2 drag_start_position{};
    glm::vec2 drag_previous_position{};

    // Treat cursor mode as bitwise, since modifier keys can apply multiple
    // simultaneous states.
    enum class GMCursorMode : unsigned
    {
        None = 0,
        SelectArea = 1 << 0,     // Drag mode, BoxSelect
        SelectShips = 1 << 1,    // Ctrl: filter box select to ships/STBOs
        SelectFaction = 1 << 2,  // Alt: filter box select to same faction
        AddToSelection = 1 << 3, // Shift: add box select to current selection
        CreateEntity = 1 << 4,   // GM click pending
        SetDirection = 1 << 5,   // CreateWithDrag direction phase
        MoveEntities = 1 << 6,   // Dragging selected objects
        SetAITarget = 1 << 7,    // Right-click order
        ZoomCamera = 1 << 8,     // Mousewheel zoom
        PanCamera = 1 << 9,      // Right-click drag pan
    } gm_cursor_mode = GMCursorMode::None;

    friend GMCursorMode operator|(GMCursorMode a, GMCursorMode b)
        { return GMCursorMode(unsigned(a) | unsigned(b)); }
    friend GMCursorMode& operator|=(GMCursorMode& a, GMCursorMode b)
        { return a = GMCursorMode(unsigned(a) | unsigned(b)); }
    friend GMCursorMode operator&(GMCursorMode a, GMCursorMode b)
        { return GMCursorMode(unsigned(a) & unsigned(b)); }

    bool has_cpu_ship = false;

    GuiButton* create_button;
    GuiButton* cancel_action_button;

    GameMasterChatDialog* getChatDialog(sp::ecs::Entity entity);

public:
    GameMasterScreen(RenderLayer* render_layer);
    virtual ~GameMasterScreen();

    virtual void update(float delta) override;

    void onMouseDown(sp::io::Pointer::Button button, glm::vec2 position);
    void onMouseDrag(glm::vec2 position);
    void onMouseUp(glm::vec2 position);
    void onMouseWheel(float value, glm::vec2 position);

    std::vector<sp::ecs::Entity> getSelection();

    string getScriptExport(bool selected_only);
};
