#include "gui2_listbox.h"

GuiListbox::GuiListbox(GuiContainer* owner, string id, func_t func)
: GuiElement(owner, id), selection_index(-1), text_size(30), button_height(50), text_alignment(ACenter), func(func)
{
    selected_color = sf::Color::White;
    unselected_color = sf::Color(192, 192, 192, 255);
    
    scroll = new GuiScrollbar(this, id + "_SCROLL", 0, 0, 0, [this](int value) {
        updateButtons();
    });
    scroll->setPosition(0, 0, ATopRight);
}

void GuiListbox::onDraw(sf::RenderTarget& window)
{
    drawElements(rect, window);
}

void GuiListbox::updateButtons()
{
    int max_buttons = size.y / button_height;
    float button_width = size.x - button_height;
    
    scroll->setSize(button_height, size.y);
    scroll->setValueSize(max_buttons);
    scroll->setRange(0, entries.size());
    if ((int)entries.size() <= max_buttons)
    {
        button_width = size.x;
        scroll->hide();
    }
    else
    {
        scroll->show();
    }

    while(buttons.size() < entries.size() && (int)buttons.size() < max_buttons)
    {
        int offset = buttons.size();
        GuiButton* button = new GuiButton(this, "", "", [this, offset](GuiButton*) {
            setSelectionIndex(offset + scroll->getValue());
        });
        button->setPosition(0, offset * button_height, ATopLeft);
        button->setColor(unselected_color);
        buttons.push_back(button);
    }
    while(buttons.size() > entries.size())
    {
        delete buttons.back();
        buttons.erase(buttons.begin() + buttons.size() - 1);
    }
    
    for(int n=0; n<(int)buttons.size(); n++)
    {
        buttons[n]->setText(entries[n + scroll->getValue()].name);
        buttons[n]->setSize(button_width, button_height);
        if (n + scroll->getValue() == selection_index)
            buttons[n]->setColor(selected_color);
        else
            buttons[n]->setColor(unselected_color);
    }
}

GuiElement* GuiListbox::onMouseDown(sf::Vector2f position)
{
    return getClickElement(position);
}

void GuiListbox::onMouseUp(sf::Vector2f position)
{
}

int GuiListbox::addEntry(string name, string value)
{
    entries.emplace_back(name, value);
    updateButtons();
    return entries.size() - 1;
}

int GuiListbox::indexByValue(string value)
{
    for(unsigned int n=0; n<entries.size(); n++)
        if (entries[n].value == value)
            return n;
    return -1;
}

void GuiListbox::removeEntry(int index)
{
    if (index < 0 || index >= (int)entries.size())
        return;
    entries.erase(entries.begin() + index);
    if (selection_index == index)
        setSelectionIndex(-1);
    if (selection_index > index)
        setSelectionIndex(selection_index - 1);
    updateButtons();
}

void GuiListbox::setSelectionIndex(int index)
{
    selection_index = index;
    updateButtons();
    if (func)
    {
        if (selection_index >= 0 && selection_index < (int)entries.size())
            func(selection_index, entries[selection_index].value);
        else
            func(selection_index, "");
    }
}
