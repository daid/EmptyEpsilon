#pragma once

#include "gui2_element.h"

class GuiThemeStyle;

class GuiRotationDial : public GuiElement
{
public:
    typedef std::function<void(float value)> func_t;
protected:
    float min_value;
    float max_value;
    float value;
    float rotation_offset = 0.0f;
    float ring_thickness = 0.0f;
    float handle_arc = 20.0f;
    float radius;
    func_t func;
    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;
public:
    GuiRotationDial(GuiContainer* owner, string id, float min_value, float max_value, float start_value, float rotation_offset, float ring_thickness, func_t func);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiRotationDial* setValue(float value);
    float getValue() const;
    GuiRotationDial* setThickness(float width) { ring_thickness = std::max(0.0f, width); return this; }
    GuiRotationDial* setRotationOffset(float offset) { rotation_offset = std::max(0.0f, offset); return this; }
    GuiRotationDial* setHandleArc(float degrees) { handle_arc = std::clamp(degrees, 1.0f, 359.0f); return this; }
private:
    float getUForSegment(int i, float arc_length, float u_corner, int handle_segments) const;
};
