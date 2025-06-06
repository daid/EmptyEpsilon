#ifndef GUI2_CONTAINERLISTBOX_H
#define GUI2_CONTAINERLISTBOX_H

#include "gui2_element.h"
#include "gui2_scrollbar.h"

/// @brief This gui element vertically displays elements encaplsulated in a scrollable way
///
/// The list of elements contained in the can be combination of GuiElement allowing for more complex layouts
class GuiElementListbox : public GuiElement
{
public:
    typedef std::function<void()> func_t;
    
protected:
    /// @brief list of elements contained in the GuiElementListbox,
    ///        this can be a combination of GuiElement allowing for more complex layouts
    std::vector<GuiElement*> elements;
    /// @brief The style for the background of the GuiElementListbox
    int element_height;
    /// @brief frame margin around the GuiElementListbox
    int frame_margin;
    /// @brief Scrollbar located on the right side of the GuiElementListbox
    GuiScrollbar* scroll;

public:
    
    GuiElementListbox(GuiContainer* owner, string id, int frame_margin, int element_height, func_t func);

    GuiElementListbox* scrollTo(int index);

    /// @brief Inserts an element to the listbox
    GuiElementListbox* addElement(GuiElement* element);

    /// @brief Sets the height of elements in the element listbox.
    GuiElementListbox* setElementHeight(int height);

    /// @brief Destroys all elements in the listbox and clears the internal list
    GuiElementListbox* destroyAndClear();


    virtual void onDraw(sp::RenderTarget& renderer) override;

protected:
    /// @brief Returns the total height of all elements in the listbox
    float getTotalHeight();


};

#endif//GUI2_LISTBOX_H
