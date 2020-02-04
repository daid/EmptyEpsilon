#ifndef RADAR_VIEW_H
#define RADAR_VIEW_H

#include "gui/gui2_element.h"

class GuiMissileTubeControls;
class TargetsContainer;

class GuiRadarView : public GuiElement
{
public:
    enum ERadarStyle
    {
        Rectangular,
        Circular,
        CircularMasked
    };
    enum EFogOfWarStyle
    {
        NoFogOfWar,
        NebulaFogOfWar,
        FriendlysShortRangeFogOfWar
    };

    typedef std::function<void(sf::Vector2f position)> func_t;
    typedef std::function<void(float position)>        ffunc_t;
private:
    sf::RenderTexture background_texture;
    sf::RenderTexture forground_texture;
    sf::RenderTexture mask_texture;

    class GhostDot
    {
    public:
        constexpr static float total_lifetime = 60.0f;

        sf::Vector2f position;
        float end_of_life;

        GhostDot(sf::Vector2f pos)
        : position(pos), end_of_life(engine->getElapsedTime() + total_lifetime) {}
    };
    std::vector<GhostDot> ghost_dots;
    float next_ghost_dot_update;

    TargetsContainer* targets;
    GuiMissileTubeControls* missile_tube_controls;

    float distance;
    sf::Vector2f view_position;
    bool long_range;
    bool show_visual_objects;
    bool show_ghost_dots;
    bool show_signal_details;
    bool show_gravity;
    float gr;
    bool show_electrical;
    float er;
    bool show_biological;
    float br;
    bool show_waypoints;
    bool show_target_projection;
    bool show_missile_tubes;
    bool show_callsigns;
    bool show_heading_indicators;
    bool show_game_master_data;
    bool auto_center_on_my_ship;
    float range_indicator_step_size;
    ERadarStyle style;
    EFogOfWarStyle fog_style;
    func_t mouse_down_func;
    func_t mouse_drag_func;
    func_t mouse_up_func;
    ffunc_t joystick_x_func;
    ffunc_t joystick_y_func;
    ffunc_t joystick_z_func;
    ffunc_t joystick_r_func;
public:
    GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets);

    virtual void onDraw(sf::RenderTarget& window);

    GuiRadarView* setDistance(float distance) { this->distance = distance; return this; }
    float getDistance() { return distance; }
    GuiRadarView* setRangeIndicatorStepSize(float step) { range_indicator_step_size = step; return this; }
    GuiRadarView* longRange() { long_range = true; return this; }
    GuiRadarView* shortRange() { long_range = false; return this; }
    GuiRadarView* enableVisualObjects() { show_visual_objects = true; return this; }
    GuiRadarView* disableVisualObjects() { show_visual_objects = false; return this; }
    GuiRadarView* enableGhostDots() { show_ghost_dots = true; return this; }
    GuiRadarView* disableGhostDots() { show_ghost_dots = false; return this; }
    GuiRadarView* enableSignalDetails() { show_signal_details = true; return this; }
    GuiRadarView* disableSignalDetails() { show_signal_details = false; return this; }
    void setSignalGravity(bool enabled) { show_gravity = enabled; }
    void setSignalElectrical(bool enabled) { show_electrical = enabled; }
    void setSignalBiological(bool enabled) { show_biological = enabled; }
    GuiRadarView* enableWaypoints() { show_waypoints = true; return this; }
    GuiRadarView* disableWaypoints() { show_waypoints = false; return this; }
    GuiRadarView* enableTargetProjections(GuiMissileTubeControls* missile_tube_controls) { show_target_projection = true; this->missile_tube_controls = missile_tube_controls; return this; }
    GuiRadarView* disableTargetProjections() { show_target_projection = false; return this; }
    GuiRadarView* enableMissileTubeIndicators() { show_missile_tubes = true; return this; }
    GuiRadarView* disableMissileTubeIndicators() { show_missile_tubes = false; return this; }
    GuiRadarView* enableCallsigns() { show_callsigns = true; return this; }
    GuiRadarView* disableCallsigns() { show_callsigns = false; return this; }
    GuiRadarView* enableHeadingIndicators() { show_heading_indicators = true; return this; }
    GuiRadarView* disableHeadingIndicators() { show_heading_indicators = false; return this; }
    GuiRadarView* gameMaster() { show_game_master_data = true; return this; }
    GuiRadarView* setStyle(ERadarStyle style) { this->style = style; return this; }
    GuiRadarView* setFogOfWarStyle(EFogOfWarStyle style) { this->fog_style = style; return this; }
    bool getAutoCentering() { return auto_center_on_my_ship; }
    GuiRadarView* setAutoCentering(bool value) { this->auto_center_on_my_ship = value; return this; }
    GuiRadarView* setCallbacks(func_t mouse_down_func, func_t mouse_drag_func, func_t mouse_up_func) { this->mouse_down_func = mouse_down_func; this->mouse_drag_func = mouse_drag_func; this->mouse_up_func = mouse_up_func; return this; }
    GuiRadarView* setJoystickCallbacks(ffunc_t joystick_x_func, ffunc_t joystick_y_func, ffunc_t joystick_z_func, ffunc_t joystick_r_func)
                  { this->joystick_x_func = joystick_x_func; this->joystick_y_func = joystick_y_func; this->joystick_z_func = joystick_z_func; this->joystick_r_func = joystick_r_func; return this; }
    GuiRadarView* setViewPosition(sf::Vector2f view_position) { this->view_position = view_position; return this; }
    sf::Vector2f getViewPosition() { return view_position; }

    sf::Vector2f worldToScreen(sf::Vector2f world_position);
    sf::Vector2f screenToWorld(sf::Vector2f screen_position);

    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    virtual bool onJoystickXYMove(sf::Vector2f position);
    virtual bool onJoystickZMove(float position);
    virtual bool onJoystickRMove(float position);
private:
    void updateGhostDots();

    void drawBackground(sf::RenderTarget& window);
    void drawSectorGrid(sf::RenderTarget& window);
    void drawNebulaBlockedAreas(sf::RenderTarget& window);
    void drawNoneFriendlyBlockedAreas(sf::RenderTarget& window);
    void drawFriendlyNotVisibleAreas(sf::RenderTarget& window);
    void drawGhostDots(sf::RenderTarget& window);
    void drawWaypoints(sf::RenderTarget& window);
    void drawRangeIndicators(sf::RenderTarget& window);
    void drawTargetProjections(sf::RenderTarget& window);
    void drawMissileTubes(sf::RenderTarget& window);
    void drawObjects(sf::RenderTarget& window_normal, sf::RenderTarget& window_alpha);
    void drawObjectsGM(sf::RenderTarget& window);
    void drawTargets(sf::RenderTarget& window);
    void drawHeadingIndicators(sf::RenderTarget& window);
    void drawRadarCutoff(sf::RenderTarget& window);
    void drawSignalDetails(sf::RenderTarget& window);
};

#endif//RADAR_VIEW_H
