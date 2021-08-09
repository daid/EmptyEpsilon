#ifndef GUI2_PROGRESSSLIDER_H
#define GUI2_PROGRESSSLIDER_H

#include "gui2_element.h"
#include "gui2_slider.h"

class GuiProgressSlider : public GuiBasicSlider
{
public:
    typedef std::function<void(float value)> func_t;
private:
    sf::Color color;
    bool drawBackground;

    string text;
public:
    GuiProgressSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sp::RenderTarget& target);
    virtual bool onMouseDown(glm::vec2 position);
    virtual void onMouseDrag(glm::vec2 position);
    virtual void onMouseUp(glm::vec2 position);

    GuiProgressSlider* setText(string text);
    GuiProgressSlider* setColor(sf::Color color);
    GuiProgressSlider* setDrawBackground(bool drawBackground);
};

#endif//GUI2_PROGRESSSLIDER_H
