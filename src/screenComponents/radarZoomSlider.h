#pragma once

#include "gui/gui2_element.h"
#include "screenComponents/radarView.h"

class GuiLabel;
class GuiSlider;

// RadarView zoom slider with mousewheel handling.
class GuiRadarZoomSlider : public GuiElement
{
private:
    GuiSlider* slider;
    GuiLabel* label;
    GuiRadarView* radar;
    float min_distance;
    float max_distance;
    float zoom_ref;
    bool custom_zoom_ref = false;
    int label_precision = 1;

    void applyDistance(float view_distance);

public:
    GuiRadarZoomSlider(GuiContainer* owner, string id, float min_distance, float max_distance, float start_value, GuiRadarView* radar);

    // Update the view distance range.
    GuiRadarZoomSlider* setRange(float new_max, float new_min);
    // Override the view distance of 1x zoom as used in the label.
    GuiRadarZoomSlider* setZoomReference(float ref);
    // Set the number of decimal places shown in the zoom multiplier label.
    GuiRadarZoomSlider* setLabelPrecision(int precision);
    // Set the slider value by view distance.
    GuiRadarZoomSlider* setValue(float value);
    // Return the slider value in view distance.
    float getValue();

    // Handle mousewheel zoom when hovering over the slider.
    virtual bool onMouseWheelScroll(glm::vec2 position, float value) override;
};
