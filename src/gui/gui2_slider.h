#ifndef GUI2_SLIDER_H
#define GUI2_SLIDER_H

#include "gui2.h"

class GuiSlider : public GuiElement
{
    typedef std::function<void(float value)> func_t;
protected:
    float min_value;
    float max_value;
    float value;
    func_t func;
public:
    GuiSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual GuiElement* onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
};

#endif//GUI2_SLIDER_H
