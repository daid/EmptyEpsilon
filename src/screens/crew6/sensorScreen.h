#ifndef SENSOR_SCREEN_H
#define SENSOR_SCREEN_H

#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"
#include "playerInfo.h"


class GuiRadarView;
class GuiGraph;
class GuiGraphLabel;
class GuiToggleButton;
class SensorScreenOverlay;

class SensorScreen : public GuiOverlay
{
protected:
    float min_arc_size;
    void setSensorTarget(glm::vec2 bearing);

    int point_count;

    float target_map_zoom;
    
    void updateMapZoom(float delta);
public:
    SensorScreen(GuiContainer* owner, CrewPosition crew_position=CrewPosition::scienceOfficer);

    GuiRadarView* radar;
    GuiGraph* electrical_graph;
    GuiGraph* biological_graph;
    GuiGraph* gravity_graph;
    GuiGraphLabel* graph_label;
    GuiToggleButton* link_probe_button;
    TargetsContainer targets;
    SensorScreenOverlay* scan_overlay;


    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//SENSOR_SCREEN_H
