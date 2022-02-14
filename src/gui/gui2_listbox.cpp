#include "gui2_listbox.h"

GuiListbox::GuiListbox(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func), text_size(30), button_height(50), text_alignment(sp::Alignment::Center)
{
    selected_color = glm::u8vec4{255,255,255,255};
    unselected_color = glm::u8vec4(192, 192, 192, 255);

    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {
        entriesChanged();
    });
    scroll->setPosition(0, 0, sp::Alignment::TopRight)->hide();
}

GuiListbox* GuiListbox::setTextSize(float size)
{
    text_size = size;
    return this;
}

GuiListbox* GuiListbox::setButtonHeight(float height)
{
    button_height = height;
    return this;
}

GuiListbox* GuiListbox::scrollTo(int index)
{
    scroll->setValue(index);
    return this;
}

void GuiListbox::onDraw(sp::RenderTarget& renderer)
{
    if (last_rect != rect)
        entriesChanged();
}

void GuiListbox::entriesChanged()
{
    last_rect = rect;

    int max_buttons = rect.size.y / button_height;
    float button_width = rect.size.x - button_height;

    scroll->setSize(button_height, rect.size.y);
    scroll->setValueSize(max_buttons);
    scroll->setRange(0, entries.size());
    if ((int)entries.size() <= max_buttons)
    {
        button_width = rect.size.x;
        scroll->hide();
    }
    else
    {
        scroll->show();
    }

    while(buttons.size() < entries.size() && (int)buttons.size() < max_buttons)
    {
        int offset = buttons.size();
        auto button = new GuiToggleButton(this, id + "_BUTTON_" + string(offset), "", [this, offset](bool) {
            setSelectionIndex(offset + scroll->getValue());
            callback();
        });
        button->setPosition(0, offset * button_height, sp::Alignment::TopLeft);
        button->setValue(false);
        buttons.push_back(button);
    }
    while(buttons.size() > entries.size())
    {
        buttons.back()->destroy();
        buttons.erase(buttons.begin() + buttons.size() - 1);
    }

    for(int n=0; n<(int)buttons.size(); n++)
    {
        buttons[n]->setText(entries[n + scroll->getValue()].name);
        buttons[n]->setSize(button_width, button_height);
        if (n + scroll->getValue() == selection_index)
            buttons[n]->setValue(true);
        else
            buttons[n]->setValue(false);
    }
}

bool GuiListbox::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return false;
}

void GuiListbox::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
}
