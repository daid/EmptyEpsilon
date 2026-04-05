#include "gui2_listbox.h"
#include "gui2_scrollcontainer.h"
#include "gui2_togglebutton.h"

GuiListbox::GuiListbox(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func)
{
    // Wrap the Listbox in a scrolling container.
    scroll_container = new GuiScrollContainer(this, id + "_SCROLL");
    scroll_container
        ->setScrollbarWidth(button_height)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("layout", "vertical");

    // Listbox theme isn't declared here because it's applied by
    // button->setStyle in entriesChanged().
}

GuiListbox* GuiListbox::setTextSize(float size)
{
    text_size = std::max(0.0f, size);
    for (auto* button : buttons) button->setTextSize(size);
    return this;
}

GuiListbox* GuiListbox::setIconSize(float size)
{
    icon_size = std::max(0.0f, size);
    for (auto* button : buttons) button->setIconSize(size);
    return this;
}

GuiListbox* GuiListbox::setButtonHeight(float height)
{
    button_height = std::max(0.0f, height);
    scroll_container->setScrollbarWidth(height);
    for (auto* button : buttons) button->setSize(GuiElement::GuiSizeMax, height);
    return this;
}

GuiListbox* GuiListbox::scrollTo(int index)
{
    scroll_container->scrollToOffset(static_cast<float>(index) * button_height);
    return this;
}

void GuiListbox::entriesChanged()
{
    // Create new buttons for entries that don't have one yet.
    for (auto n = buttons.size(); n < entries.size(); n++)
    {
        auto* btn = new GuiToggleButton(scroll_container, id + "_ENTRY_" + string(static_cast<int>(n)), entries[n].name,
            [this, n](bool)
            {
                setSelectionIndex(n);
                callback();
            }
        );
        btn
            ->setStyle("listbox") // Use listbox-specific theme styles.
            ->setTextSize(text_size)
            ->setIconSize(icon_size)
            ->setSize(GuiElement::GuiSizeMax, button_height);
        buttons.push_back(btn);
    }

    updateButtonStates();
}

void GuiListbox::updateButtonStates()
{
    // Select only one button in the list.
    for (size_t n = 0; n < buttons.size(); n++)
    {
        if (n < entries.size())
        {
            buttons[n]
                ->setValue(static_cast<int>(n) == selection_index)
                ->setText(entries[n].name)
                ->setIcon(entries[n].icon_name)
                ->show();
        }
        else buttons[n]->hide();
    }
}
