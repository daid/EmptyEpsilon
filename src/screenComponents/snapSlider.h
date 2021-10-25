#ifndef SNAP_SLIDER_H
#define SNAP_SLIDER_H

#include "gui/gui2_slider.h"

class GuiSnapSlider : public GuiSlider
{
private:
    float snap_value;
public:
    GuiSnapSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

class GuiSnapSlider2D : public GuiSlider2D
{
private:
    glm::vec2 snap_value;
public:
    GuiSnapSlider2D(GuiContainer* owner, string id, glm::vec2 min_value, glm::vec2 max_value, glm::vec2 start_value, func_t func);

    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//SNAP_SLIDER_H
