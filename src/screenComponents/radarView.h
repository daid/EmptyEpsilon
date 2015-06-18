#ifndef GUI_RADAR_VIEW_H
#define GUI_RADAR_VIEW_H

#include "spaceObjects/spaceObject.h"
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
    
    typedef std::function<void(sf::Vector2f position)> func_t;
private:
    PVector<SpaceObject> targets;

    float distance;
    sf::Vector2f view_position;
    bool long_range;
    bool show_callsigns;
    bool show_game_master_data;
    float range_indicator_step_size;
    ERadarStyle style;
    func_t mouse_down_func;
    func_t mouse_drag_func;
    func_t mouse_up_func;
public:
    GuiRadarView(GuiContainer* owner, string id, float distance);

    virtual void onDraw(sf::RenderTarget& window);

    GuiRadarView* setDistance(float distance) { this->distance = distance; return this; }
    float getDistance() { return distance; }
    GuiRadarView* setRangeIndicatorStepSize(float step) { range_indicator_step_size = step; return this; }
    GuiRadarView* longRange() { long_range = true; return this; }
    GuiRadarView* shortRange() { long_range = false; return this; }
    GuiRadarView* enableCallsigns() { show_callsigns = true; return this; }
    GuiRadarView* disableCallsigns() { show_callsigns = false; return this; }
    GuiRadarView* gameMaster() { show_game_master_data = true; return this; }
    GuiRadarView* setStyle(ERadarStyle style) { this->style = style; return this; }
    GuiRadarView* setCallbacks(func_t mouse_down_func, func_t mouse_drag_func, func_t mouse_up_func) { this->mouse_down_func = mouse_down_func; this->mouse_drag_func = mouse_drag_func; this->mouse_up_func = mouse_up_func; return this; }
    GuiRadarView* setViewPosition(sf::Vector2f view_position) { this->view_position = view_position; return this; }
    sf::Vector2f getViewPosition() { return view_position; }
    GuiRadarView* clearTargets() { targets.clear(); return this; }
    GuiRadarView* addTarget(P<SpaceObject> obj) { if (obj) targets.push_back(obj); return this; }
    GuiRadarView* setTarget(P<SpaceObject> obj);
    GuiRadarView* setTargets(PVector<SpaceObject> objs);
    PVector<SpaceObject> getTargets() { return targets; }
    
    sf::Vector2f worldToScreen(sf::Vector2f world_position);
    sf::Vector2f screenToWorld(sf::Vector2f screen_position);

    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
private:
    void drawBackground(sf::RenderTarget& window);
    void drawSectorGrid(sf::RenderTarget& window);
    void drawRangeIndicators(sf::RenderTarget& window);
    void drawObjects(sf::RenderTarget& window);
    void drawObjectsGM(sf::RenderTarget& window);
    void drawTargets(sf::RenderTarget& window);
    void drawRadarCutoff(sf::RenderTarget& window);
};

#endif//GUI_RADAR_VIEW_H
