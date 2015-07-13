#ifndef GUI_RADAR_VIEW_H
#define GUI_RADAR_VIEW_H

#include "targetsContainer.h"
#include "gui/gui2.h"

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
private:
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
    
    float distance;
    sf::Vector2f view_position;
    bool long_range;
    bool show_ghost_dots;
    bool show_waypoints;
    bool show_target_projection;
    bool show_callsigns;
    bool show_heading_indicators;
    bool show_game_master_data;
    float range_indicator_step_size;
    float missile_target_angle;
    ERadarStyle style;
    EFogOfWarStyle fog_style;
    func_t mouse_down_func;
    func_t mouse_drag_func;
    func_t mouse_up_func;
public:
    GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets);

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
    GuiRadarView* enableTargetProjections() { show_target_projection = true; return this; }
    GuiRadarView* disableTargetProjections() { show_target_projection = false; return this; }
    GuiRadarView* enableCallsigns() { show_callsigns = true; return this; }
    GuiRadarView* disableCallsigns() { show_callsigns = false; return this; }
    GuiRadarView* enableHeadingIndicators() { show_heading_indicators = true; return this; }
    GuiRadarView* disableHeadingIndicators() { show_heading_indicators = false; return this; }
    GuiRadarView* gameMaster() { show_game_master_data = true; return this; }
    GuiRadarView* setStyle(ERadarStyle style) { this->style = style; return this; }
    GuiRadarView* setFogOfWarStyle(EFogOfWarStyle style) { this->fog_style = style; return this; }
    GuiRadarView* setCallbacks(func_t mouse_down_func, func_t mouse_drag_func, func_t mouse_up_func) { this->mouse_down_func = mouse_down_func; this->mouse_drag_func = mouse_drag_func; this->mouse_up_func = mouse_up_func; return this; }
    GuiRadarView* setViewPosition(sf::Vector2f view_position) { this->view_position = view_position; return this; }
    sf::Vector2f getViewPosition() { return view_position; }
    void setMissileTargetAngle(float angle) { missile_target_angle = angle; }
    
    sf::Vector2f worldToScreen(sf::Vector2f world_position);
    sf::Vector2f screenToWorld(sf::Vector2f screen_position);

    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
private:
    void updateGhostDots();
    
    void drawBackground(sf::RenderTarget& window);
    void drawSectorGrid(sf::RenderTarget& window);
    void drawNebulaBlockedAreas(sf::RenderTarget& window);
    void drawFriendlyNotVisibleAreas(sf::RenderTarget& window);
    void drawGhostDots(sf::RenderTarget& window);
    void drawWaypoints(sf::RenderTarget& window);
    void drawRangeIndicators(sf::RenderTarget& window);
    void drawTargetProjections(sf::RenderTarget& window);
    void drawObjects(sf::RenderTarget& window);
    void drawObjectsGM(sf::RenderTarget& window);
    void drawTargets(sf::RenderTarget& window);
    void drawHeadingIndicators(sf::RenderTarget& window);
    void drawRadarCutoff(sf::RenderTarget& window);
};

#endif//GUI_RADAR_VIEW_H
