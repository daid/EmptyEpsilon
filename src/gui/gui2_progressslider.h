#ifndef GUI2_PROGRESSSLIDER_H
#define GUI2_PROGRESSSLIDER_H

#include "gui2_element.h"
#include "gui2_progressbar.h"

class GuiProgressSlider : public GuiProgressbar
{
public:
    typedef std::function<void(float value)> func_t;

    GuiProgressSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

private:
    func_t callback;
};

#endif//GUI2_PROGRESSSLIDER_H
