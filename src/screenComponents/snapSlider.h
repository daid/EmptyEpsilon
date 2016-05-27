#ifndef SNAP_SLIDER_H
#define SNAP_SLIDER_H

#include "gui/gui2_slider.h"

class GuiSnapSlider : public GuiSlider
{
private:
    float snap_value;
public:
    GuiSnapSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);
    
    virtual void onMouseUp(sf::Vector2f position);
};

class GuiSnapSlider2D : public GuiSlider2D
{
private:
    sf::Vector2f snap_value;
public:
    GuiSnapSlider2D(GuiContainer* owner, string id, sf::Vector2f min_value, sf::Vector2f max_value, sf::Vector2f start_value, func_t func);
    
    virtual void onMouseUp(sf::Vector2f position);
};

#endif//SNAP_SLIDER_H
