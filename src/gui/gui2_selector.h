#ifndef GUI2_SELECTOR_H
#define GUI2_SELECTOR_H

#include "gui2.h"

class GuiSelector : public GuiElement
{
    typedef std::function<void(int)> func_t;
protected:
    std::vector<string> options;
    int index;
    float text_size;
    EGuiAlign text_alignment;
    func_t func;
public:
    GuiSelector(GuiContainer* owner, string id, std::vector<string> options, int selected_index, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual GuiElement* onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
};

#endif//GUI2_SELECTOR_H

