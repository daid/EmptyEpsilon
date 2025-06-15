#ifndef RADAR_VIEW_H
#define RADAR_VIEW_H

#include "gui/gui2_element.h"
#include "engine.h"


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

    typedef std::function<void(sp::io::Pointer::Button button, glm::vec2 position)> bpfunc_t;
    typedef std::function<void(glm::vec2 position)> pfunc_t;
    typedef std::function<void(float position)>     ffunc_t;
    
private:
    class GhostDot
    {
    public:
        constexpr static float total_lifetime = 60.0f;

        glm::vec2 position{};
        float end_of_life;

        GhostDot(glm::vec2 pos) : position(pos), end_of_life(engine->getElapsedTime() + total_lifetime) {}
    };
    std::vector<GhostDot> ghost_dots;
    float next_ghost_dot_update;

    TargetsContainer* targets;
    GuiMissileTubeControls* missile_tube_controls;

    glm::vec2 view_position{0, 0};
    float view_rotation;
    bool auto_center_on_my_ship;
    bool auto_rotate_on_my_ship;
    bool auto_distance = false;
    float distance;
    bool long_range;
    bool show_ghost_dots;
    bool show_waypoints;
    bool show_target_projection;
    bool show_missile_tubes;
    bool show_callsigns;
    bool show_heading_indicators;
    bool show_signatures;
    bool show_electrical;
    bool show_gravity;
    bool show_biological;
    bool show_game_master_data;
    float range_indicator_step_size;
    uint8_t background_alpha;
    ERadarStyle style;
    EFogOfWarStyle fog_style;
    bpfunc_t mouse_down_func;
    pfunc_t mouse_drag_func;
    pfunc_t mouse_up_func;
public:
    GuiRadarView(GuiContainer* owner, string id, TargetsContainer* targets);
    GuiRadarView(GuiContainer* owner, string id, float distance, TargetsContainer* targets);

    virtual void onDraw(sp::RenderTarget& target) override;

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
    GuiRadarView* setBackgroundAlpha(uint8_t background_alpha) { this->background_alpha = background_alpha; return this; }
    GuiRadarView* setStyle(ERadarStyle style) { this->style = style; return this; }
    GuiRadarView* setFogOfWarStyle(EFogOfWarStyle style) { this->fog_style = style; return this; }
    bool getAutoCentering() { return auto_center_on_my_ship; }
    GuiRadarView* setAutoCentering(bool value) { this->auto_center_on_my_ship = value; return this; }
    bool getAutoRotating() { return auto_rotate_on_my_ship; }
    GuiRadarView* setAutoRotating(bool value) { this->auto_rotate_on_my_ship = value; return this; }
    GuiRadarView* setCallbacks(bpfunc_t mouse_down_func, pfunc_t mouse_drag_func, pfunc_t mouse_up_func) { this->mouse_down_func = mouse_down_func; this->mouse_drag_func = mouse_drag_func; this->mouse_up_func = mouse_up_func; return this; }
    GuiRadarView* setViewPosition(glm::vec2 view_position) { this->view_position = view_position; return this; }
    glm::vec2 getViewPosition() { return view_position; }
    GuiRadarView* setViewRotation(float view_rotation) { this->view_rotation = view_rotation; return this; }
    float getViewRotation() { return view_rotation; }

    GuiRadarView* enableSignatures() { show_signatures = true; return this; }
    GuiRadarView* disableSignatures() { show_signatures = false; return this; }
    bool getSignatures() { return show_signatures; }
    GuiRadarView* enableElectrical() { show_electrical = true; return this; }
    GuiRadarView* disableElectrical() { show_electrical = false; return this; }
    bool getElectrical() { return show_electrical; }
    GuiRadarView* enableGravity() { show_gravity = true; return this; }
    GuiRadarView* disableGravity() { show_gravity = false; return this; }
    bool getGravity() { return show_gravity; }
    GuiRadarView* enableBiological() { show_biological = true; return this; }
    GuiRadarView* disableBiological() { show_biological = false; return this; }
    bool getBiological() { return show_biological; }

    glm::vec2 worldToScreen(glm::vec2 world_position);
    glm::vec2 screenToWorld(glm::vec2 screen_position);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
private:
    void updateGhostDots();

    void drawBackground(sp::RenderTarget& target);
    void drawSectorGrid(sp::RenderTarget& target);
    void drawNebulaBlockedAreas(sp::RenderTarget& target);
    void drawNoneFriendlyBlockedAreas(sp::RenderTarget& target);
    void drawFriendlyNotVisibleAreas(sp::RenderTarget& target);
    void drawGhostDots(sp::RenderTarget& target);
    void drawWaypoints(sp::RenderTarget& target);
    void drawRangeIndicators(sp::RenderTarget& target);
    void drawTargetProjections(sp::RenderTarget& target);
    void drawMissileTubes(sp::RenderTarget& target);
    void drawObjects(sp::RenderTarget& target);
    void drawObjectsGM(sp::RenderTarget& target);
    void drawTargets(sp::RenderTarget& target);
    void drawHeadingIndicators(sp::RenderTarget& target);
};

#endif//RADAR_VIEW_H
