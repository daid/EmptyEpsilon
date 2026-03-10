#pragma once

#include "gui2_entrylist.h"

class GuiScrollContainer;
class GuiToggleButton;

// Creates a scrolling list of buttons to represent an entry list. Clicking a
// button selects that value in the list. Supports only one selection at a time.
class GuiListbox : public GuiEntryList
{
protected:
    // The font size for the buttons' text, in virtual pixels.
    float text_size = 30.0f;
    // The buttons' icon size, as a normalized factor of button height
    // (0.0-1.0 = 0-100%).
    float icon_size = 0.6f;
    // The buttons' height, in virtual pixels.
    float button_height = 50.0f;
public:
    GuiListbox(GuiContainer* owner, string id, func_t func);

    // Set the font size for the buttons' text, in virtual pixels.
    GuiListbox* setTextSize(float size);
    // Set the buttons' icon size, as a normalized factor of button height
    // (0.0-1.0 = 0-100%).
    GuiListbox* setIconSize(float size);
    // Set the buttons' height, in virtual pixels.
    GuiListbox* setButtonHeight(float height);
    // Scroll the listbox to the item with the given index.
    GuiListbox* scrollTo(int index);

private:
    // Scrolling container wrapping the button list.
    GuiScrollContainer* scroll_container;
    // Vector of toggle buttons representing list items.
    std::vector<GuiToggleButton*> buttons;

    // Update the listbox when its entries change.
    virtual void entriesChanged() override;
    // Update listbox button selection states.
    void updateButtonStates();
};
