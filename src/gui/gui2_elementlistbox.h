#ifndef GUI2_CONTAINERLISTBOX_H
#define GUI2_CONTAINERLISTBOX_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

/// @brief This gui element vertically displays elements encaplsulated in a scrollable way
///
/// The list of elements contained in the can be combination of GuiElement allowing for more complex layouts
class GuiElementListbox : public GuiElement
{
    
protected:
    int element_height;
    int frame_margin;
    GuiScrollbar* scroll;
    int mouse_scroll_steps;

public:
    
    GuiElementListbox(GuiContainer* owner, string id, int frame_margin, int element_height);

    GuiElementListbox* scrollTo(int index);

    GuiElementListbox* setElementHeight(int height);

    GuiElementListbox* destroyAndClear();

    virtual void onDraw(sp::RenderTarget& renderer) override;

    virtual bool onMouseWheelScroll(glm::vec2 position, float value) override;

protected:
    float getTotalHeight();


};

#endif//GUI2_LISTBOX_H
