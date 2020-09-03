#include "gui2_listbox.h"

GuiListbox::GuiListbox(GuiContainer* owner, string id, func_t func)
: GuiEntryList(owner, id, func), text_size(30), button_height(50), text_alignment(ACenter)
{
    selected_color = sf::Color::White;
    unselected_color = sf::Color(192, 192, 192, 255);

    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {
        entriesChanged();
    });
    scroll->setPosition(0, 0, ATopRight)->hide();
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

void GuiListbox::onDraw(sf::RenderTarget& window)
{
    if (last_rect != rect)
        entriesChanged();
}

void GuiListbox::entriesChanged()
{
    last_rect = rect;

    int max_buttons = rect.height / button_height;
    float button_width = rect.width - button_height;

    scroll->setSize(button_height, rect.height);
    scroll->setValueSize(max_buttons);
    scroll->setRange(0, entries.size());
    if ((int)entries.size() <= max_buttons)
    {
        button_width = rect.width;
        scroll->hide();
    }
    else
    {
        scroll->show();
    }

    while(buttons.size() < entries.size() && (int)buttons.size() < max_buttons)
    {
        int offset = buttons.size();
        GuiButton* button = new GuiButton(this, id + "_BUTTON_" + string(offset), "", [this, offset]() {
            setSelectionIndex(offset + scroll->getValue());
            callback();
        });
        button->setPosition(0, offset * button_height, ATopLeft);
        button->setActive(false);
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
            buttons[n]->setActive(true);
        else
            buttons[n]->setActive(false);
    }
}

bool GuiListbox::onMouseDown(sf::Vector2f position)
{
    return false;
}

void GuiListbox::onMouseUp(sf::Vector2f position)
{
}
