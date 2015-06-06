#ifndef GUI2_SCROLLBAR_H
#define GUI2_SCROLLBAR_H

#include "gui2.h"

class GuiScrollbar : public GuiElement, private GuiContainer
{
    typedef std::function<void(int value)> func_t;
protected:
    int min_value;
    int max_value;
    int value;
    int value_size;
    func_t func;
public:
    GuiScrollbar(GuiContainer* owner, string id, int min_value, int max_value, int start_value, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual GuiElement* onMouseDown(sf::Vector2f position);
    virtual void onMouseDrag(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    void setRange(int min_value, int max_value);
    void setValueSize(int size);
    
    void setValue(int value);
    int getValue();
};

#endif//GUI2_SLIDER_H
