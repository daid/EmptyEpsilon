#ifndef GUI2_SLIDER_H
#define GUI2_SLIDER_H

#include "gui2_element.h"
#include "gui2_label.h"

class GuiSlider : public GuiElement
{
public:
    typedef std::function<void(float value)> func_t;
protected:
    float min_value;
    float max_value;
    float value;
    float snap_value;
    float snap_range;
    func_t func;
    sf::Keyboard::Key up_hotkey, down_hotkey;
    GuiLabel* overlay_label;
public:
    GuiSlider(GuiContainer* owner, string id, float min_value, float max_value, float start_value, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    virtual bool onHotkey(sf::Keyboard::Key key, int unicode);
    
    GuiSlider* setSnapValue(float value, float range);
    GuiSlider* setValue(float value);
    GuiSlider* addOverlay();
    float getValue();
};

#endif//GUI2_SLIDER_H
