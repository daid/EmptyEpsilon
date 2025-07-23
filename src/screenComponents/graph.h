#pragma once

#include "gui/gui2_element.h"

class GuiGraph : public GuiElement
{
private:
    std::vector<float> data;
    bool auto_scale_y;
    bool show_axis_zero;
    float y_min;
    float y_max;
    glm::u8vec4 color;
    std::function<void(glm::vec2)> on_drag_callback;

public:
    GuiGraph(GuiContainer *owner, string id, glm::u8vec4 color);

    GuiGraph *showAxisZero(bool value){show_axis_zero = value; return this;};
    void updateData(std::vector<float> data);
    GuiGraph *setYlimit(float min, float max);
    GuiGraph *setAutoScaleY(bool value) { auto_scale_y = value; return this;}
    GuiGraph *setColor(glm::u8vec4 value) {color = value; return this;}
    GuiGraph *setOnDragCallback(std::function<void(glm::vec2)> callback) { on_drag_callback = callback; return this; }

    virtual void onDraw(sp::RenderTarget &renderer) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
};
