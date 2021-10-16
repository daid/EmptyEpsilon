#ifndef GUI2_ROTATIONDIAL_H
#define GUI2_ROTATIONDIAL_H

#include "gui2_element.h"

class GuiRotationDial : public GuiElement
{
public:
    typedef std::function<void(float value)> func_t;
protected:
    float min_value;
    float max_value;
    float value;
    func_t func;
public:
    GuiRotationDial(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiRotationDial* setValue(float value);
    float getValue() const;
};

#endif//GUI2_ROTATIONDIAL_H
