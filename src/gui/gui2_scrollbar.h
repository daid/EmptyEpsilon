#ifndef GUI2_SCROLLBAR_H
#define GUI2_SCROLLBAR_H

#include "gui2_element.h"

class GuiScrollbar : public GuiElement
{
    typedef std::function<void(int value)> func_t;
protected:
    int min_value;
    int max_value;
    // WARNING: this value could be out of bounds. Use getValue() to ensure a value between min_value and max_value.
    int desired_value;
    int value_size;
    func_t func;

    bool drag_scrollbar;
    float drag_select_offset;
public:
    GuiScrollbar(GuiContainer* owner, string id, int min_value, int max_value, int start_value, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);

    void setRange(int min_value, int max_value);
    void setValueSize(int size);

    void setValue(int value);
    int getValue() const;

    int getMax() const;
    int getMin() const;
};

#endif//GUI2_SCROLLBAR_H
