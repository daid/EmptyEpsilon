#ifndef GUI2_PROGRESSSLIDER_H
#define GUI2_PROGRESSSLIDER_H

#include "gui2_element.h"
#include "gui2_slider.h"

class GuiProgressSlider : public GuiBasicSlider
{
public:
    typedef std::function<void(float value)> func_t;
private:
    glm::u8vec4 color;
    bool drawBackground;

    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;

    string text;
public:
    GuiProgressSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseDrag(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiProgressSlider* setText(string text);
    GuiProgressSlider* setColor(glm::u8vec4 color);
    GuiProgressSlider* setDrawBackground(bool drawBackground);
};

#endif//GUI2_PROGRESSSLIDER_H
