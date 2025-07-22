#ifndef RAW_SCANNER_DATA_RADAR_OVERLAY_H
#define RAW_SCANNER_DATA_RADAR_OVERLAY_H

#include "gui/gui2_element.h"
#include <cmath>

class GuiRadarView;

// Class to show the scan bearings and markers
class SensorScreenOverlay : public GuiElement
{
public:
    SensorScreenOverlay(GuiRadarView *owner, string id);

    void addMarker();
    void removePreviousMarker();
    void removeOldestMarker();
    void clearMarkers();

    void setBearing(float value) { bearing = value; }
    float getBearing() const { return bearing; }

    void setArc(float value) { arc = value; }
    float getArc() const { return arc; }

    void setTargetLock(bool value) {target_lock = value;}

    void setCurrentTarget(glm::vec2 screen_position);
    glm::vec2 getCurrentTarget() const { return current_target; }

    virtual void onDraw(sp::RenderTarget &target) override;

protected:
    struct Marker
    {
        glm::vec2 position;
        float bearing;
    };
    std::vector<Marker> marker_list;

    bool target_lock;
    glm::vec2 current_target;

    float bearing;
    float arc;
    GuiRadarView *radar;
};

#endif // RAW_SCANNER_DATA_RADAR_OVERLAY_H
