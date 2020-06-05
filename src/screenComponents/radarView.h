#ifndef RADAR_VIEW_H
#define RADAR_VIEW_H

#include "gui/gui2_element.h"
#include "spaceObjects/playerSpaceship.h"
#include "preferenceManager.h"

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

        GhostDot(sf::Vector2f pos) : position(pos), end_of_life(engine->getElapsedTime() + total_lifetime) {}
    };
    std::vector<GhostDot> ghost_dots;
    float next_ghost_dot_update;

    TargetsContainer* targets;
    GuiMissileTubeControls* missile_tube_controls;
    
public:
    static const int grid_scale_size = 5;

private:
    static const int sub_sectors_count = 8;
    sf::Color grid_colors[grid_scale_size];
    sf::Vector2f view_position;
    float view_rotation;
    bool auto_center_on_my_ship;
    bool auto_rotate_on_my_ship;
    bool auto_distance = false;
    float distance;
    P<PlayerSpaceship> target_spaceship;
    bool long_range;
    bool show_ghost_dots;
    bool show_sectors;
    bool show_waypoints;
    bool show_target_projection;
    bool show_missile_tubes;
    bool show_callsigns;
    bool show_heading_indicators;
    bool show_game_master_data;
    float range_indicator_step_size;
    ERadarStyle style;
    EFogOfWarStyle fog_style;
    func_t mouse_down_func;
    func_t mouse_drag_func;
    func_t mouse_up_func;
public:
    GuiRadarView(GuiContainer* owner, string id, TargetsContainer* targets, P<PlayerSpaceship> targetSpaceship);
    GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets, P<PlayerSpaceship> targetSpaceship);

    virtual void onDraw(sf::RenderTarget& window);

    GuiRadarView* setDistance(float distance) { this->distance = distance; return this; }
    float getDistance() { return distance; }
    GuiRadarView* setRangeIndicatorStepSize(float step) { range_indicator_step_size = step; return this; }
    GuiRadarView* longRange() { long_range = true; return this; }
    GuiRadarView* shortRange() { long_range = false; return this; }
    GuiRadarView* enableGhostDots() { show_ghost_dots = true; return this; }
    GuiRadarView* disableGhostDots() { show_ghost_dots = false; return this; }
    GuiRadarView* enableWaypoints() { show_waypoints = true; return this; }
    GuiRadarView* disableWaypoints() { show_waypoints = false; return this; }
    GuiRadarView* enableTargetProjections(GuiMissileTubeControls* missile_tube_controls) { show_target_projection = true; this->missile_tube_controls = missile_tube_controls; return this; }
    GuiRadarView* disableTargetProjections() { show_target_projection = false; return this; }
    GuiRadarView* enableMissileTubeIndicators() { show_missile_tubes = true; return this; }
    GuiRadarView* disableMissileTubeIndicators() { show_missile_tubes = false; return this; }
    GuiRadarView* enableCallsigns() { show_callsigns = true; return this; }
    GuiRadarView* disableCallsigns() { show_callsigns = false; return this; }
    GuiRadarView* showCallsigns(bool value) { show_callsigns = value; return this; }
    bool getCallsigns() { return show_callsigns; }
    GuiRadarView* enableHeadingIndicators() { show_heading_indicators = true; return this; }
    GuiRadarView* disableHeadingIndicators() { show_heading_indicators = false; return this; }
    GuiRadarView* gameMaster() { show_game_master_data = true; return this; }
    GuiRadarView* setStyle(ERadarStyle style) { this->style = style; return this; }
    GuiRadarView* setFogOfWarStyle(EFogOfWarStyle style) { this->fog_style = style; return this; }
    bool getAutoCentering() { return auto_center_on_my_ship; }
    GuiRadarView* setAutoCentering(bool value) { this->auto_center_on_my_ship = value; return this; }
    bool getAutoRotating() { return auto_rotate_on_my_ship; }
    GuiRadarView* setAutoRotating(bool value) { this->auto_rotate_on_my_ship = value; return this; }
    bool getShowSectors() { return show_sectors; }
    GuiRadarView* setShowSectors(bool value) { this->show_sectors = value; return this; }
    GuiRadarView* setCallbacks(func_t mouse_down_func, func_t mouse_drag_func, func_t mouse_up_func) { this->mouse_down_func = mouse_down_func; this->mouse_drag_func = mouse_drag_func; this->mouse_up_func = mouse_up_func; return this; }
    GuiRadarView* setViewPosition(sf::Vector2f view_position) { this->view_position = view_position; return this; }
    sf::Vector2f getViewPosition() { return view_position; }
    GuiRadarView* setViewRotation(float view_rotation) { this->view_rotation = view_rotation; return this; }
    float getViewRotation() { return view_rotation; }
    int calcGridScaleMagnitude(int scale_magnitude, int position);
    virtual float getScale();

    sf::Vector2f worldToScreen(sf::Vector2f world_position);
    sf::Vector2f screenToWorld(sf::Vector2f screen_position);

    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    void setTargetSpaceship(P<PlayerSpaceship> targetSpaceship){target_spaceship = targetSpaceship;}

protected:
    virtual sf::Vector2f getCenterPosition();

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
    float getRadius();
};

#endif//RADAR_VIEW_H
