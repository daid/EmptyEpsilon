#ifndef SPECTATOR_SCREEN_H
#define SPECTATOR_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/targetsContainer.h"
#include "Updatable.h"

class GuiKeyValueDisplay;
class GuiRadarView;
class GuiLabel;
class GuiSelector;
class GuiSlider;
class GuiToggleButton;
class GuiHelpOverlay;

class SpectatorScreen : public GuiCanvas, public Updatable
{
private:
    bool dragging = false;

    GuiRadarView* main_radar;

    glm::vec2 drag_start_position{};
    glm::vec2 drag_previous_position{};

    void toggleUI();
public:
    SpectatorScreen(RenderLayer* render_layer);
    virtual ~SpectatorScreen() = default;

    sp::ecs::Entity target;
    GuiToggleButton* ui_toggle;
    GuiElement* info_layout;
    GuiElement* info_coordinates;
    GuiSlider* zoom_slider;
    GuiLabel* zoom_label;
    GuiKeyValueDisplay* info_coordinates_x;
    GuiKeyValueDisplay* info_coordinates_y;
    GuiKeyValueDisplay* info_coordinates_sector;
    GuiKeyValueDisplay* info_clock;
    GuiKeyValueDisplay* info_position;
    GuiToggleButton* info_position_lock;
    std::vector<GuiKeyValueDisplay*> info_items;
    GuiElement* camera_lock_controls;
    GuiSelector* camera_lock_selector;
    GuiHelpOverlay* keyboard_help;

    virtual void update(float delta) override;

    void onMouseDown(glm::vec2 position);
    void onMouseDrag(glm::vec2 position);
    void onMouseUp(glm::vec2 position);
};


#endif//SPECTATOR_SCREEN_H
