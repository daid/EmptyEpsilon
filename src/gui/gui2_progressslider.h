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

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    GuiProgressSlider* setText(string text);
    GuiProgressSlider* setColor(sf::Color color);
    GuiProgressSlider* setDrawBackground(bool drawBackground);
};

#endif//GUI2_PROGRESSSLIDER_H
