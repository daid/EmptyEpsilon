#ifndef GUI2_CONTAINERLISTBOX_H
#define GUI2_CONTAINERLISTBOX_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

/// @brief This gui element vertically displays elements that are scrollable
class GuiElementListbox : public GuiElement
{
public:
    typedef std::function<void()> func_t;
    
protected:
    std::vector<GuiElement*> elements;
    int element_height;
    int frame_margin;
    GuiScrollbar* scroll;

    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_selected_style;
    const GuiThemeStyle* front_selected_style;

public:
    
    GuiElementListbox(GuiContainer* owner, string id, int frame_margin, int element_height, func_t func);

    GuiElementListbox* scrollTo(int index);
    GuiElementListbox* addElement(GuiElement* element);

    GuiElementListbox* setElementHeight(int height);

    GuiElementListbox* destroyAndClear();


    virtual void onDraw(sp::RenderTarget& renderer) override;

protected:
    float getTotalHeight();


};

#endif//GUI2_LISTBOX_H
