#include "radarZoomSlider.h"
#include <i18n.h>

#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"

GuiRadarZoomSlider::GuiRadarZoomSlider(GuiContainer* owner, string id, float min_distance, float max_distance, float start_value, GuiRadarView* radar)
: GuiElement(owner, id), radar(radar), min_distance(min_distance), max_distance(max_distance), zoom_ref(max_distance)
{
    slider = new GuiSlider(this, "", max_distance, min_distance, start_value,
        [this](float value)
        {
            this->radar->setDistance(value);
            label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(zoom_ref / value, label_precision)}}));
        }
    );
    slider->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    label = new GuiLabel(slider, "", tr("Zoom: {zoom}x").format({{"zoom", string(1.0f, label_precision)}}), 30.0f);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void GuiRadarZoomSlider::applyDistance(float view_distance)
{
    if (min_distance > max_distance) min_distance = max_distance;
    view_distance = std::clamp(view_distance, min_distance, max_distance);
    radar->setDistance(view_distance);
    slider->setValue(view_distance);
    label->setText(tr("Zoom: {zoom}x").format({{"zoom", string(zoom_ref / view_distance, label_precision)}}));
}

GuiRadarZoomSlider* GuiRadarZoomSlider::setRange(float new_max, float new_min)
{
    max_distance = new_max;
    min_distance = new_min;
    if (!custom_zoom_ref) zoom_ref = new_max;
    slider->setRange(new_max, new_min);
    return this;
}

GuiRadarZoomSlider* GuiRadarZoomSlider::setZoomReference(float ref)
{
    zoom_ref = ref;
    custom_zoom_ref = true;
    return this;
}

GuiRadarZoomSlider* GuiRadarZoomSlider::setLabelPrecision(int precision)
{
    label_precision = precision;
    applyDistance(slider->getValue());
    return this;
}

GuiRadarZoomSlider* GuiRadarZoomSlider::setValue(float value)
{
    applyDistance(value);
    return this;
}

float GuiRadarZoomSlider::getValue()
{
    return slider->getValue();
}

bool GuiRadarZoomSlider::onMouseWheelScroll(glm::vec2 position, float value)
{
    applyDistance(radar->getDistance() * (1.0f - value * 0.1f));
    return true;
}
