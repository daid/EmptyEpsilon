#include "gui2_entrylist.h"

GuiEntryList::GuiEntryList(GuiContainer* owner, string id, func_t func)
: GuiElement(owner, id), selection_index(-1), func(func)
{
}

GuiEntryList* GuiEntryList::setOptions(std::vector<string> options)
{
    entries.clear();
    for(string option : options)
    {
        entries.emplace_back(option, option);
    }
    entriesChanged();
    return this;
}

GuiEntryList* GuiEntryList::setOptions(std::vector<string> options, std::vector<string> values)
{
    for(unsigned int n=0; n<options.size(); n++)
    {
        if (n < values.size())
            entries.emplace_back(options[n], values[n]);
    }
    entriesChanged();
    return this;
}

void GuiEntryList::setEntryName(int index, string name)
{
    if (index < 0 || index >= (int)entries.size())
        return;
    entries[index].name = name;
    entriesChanged();
}

void GuiEntryList::setEntryValue(int index, string value)
{
    if (index < 0 || index >= (int)entries.size())
        return;
    entries[index].value = value;
    entriesChanged();
}

void GuiEntryList::setEntry(int index, string name, string value)
{
    if (index < 0 || index >= (int)entries.size())
        return;
    entries[index].value = value;
    entries[index].name = name;
    entriesChanged();
}

int GuiEntryList::addEntry(string name, string value)
{
    entries.emplace_back(name, value);
    entriesChanged();
    return entries.size() - 1;
}

int GuiEntryList::indexByValue(string value) const
{
    for(unsigned int n=0; n<entries.size(); n++)
        if (entries[n].value == value)
            return n;
    return -1;
}

void GuiEntryList::removeEntry(int index)
{
    if (index < 0 || index >= (int)entries.size())
        return;
    entries.erase(entries.begin() + index);
    if (selection_index == index)
        setSelectionIndex(-1);
    if (selection_index > index)
        setSelectionIndex(selection_index - 1);
    entriesChanged();
}

int GuiEntryList::entryCount() const
{
    return entries.size();
}

string GuiEntryList::getEntryName(int index) const
{
    if (index < 0 || index >= int(entries.size()))
        return "";
    return entries[index].name;
}

string GuiEntryList::getEntryValue(int index) const
{
    if (index < 0 || index >= int(entries.size()))
        return "";
    return entries[index].value;
}

int GuiEntryList::getSelectionIndex() const
{
    return selection_index;
}

GuiEntryList* GuiEntryList::setSelectionIndex(int index)
{
    selection_index = index;
    entriesChanged();
    return this;
}

string GuiEntryList::getSelectionValue() const
{
    if (selection_index < 0 || selection_index >= (int)entries.size())
        return "";
    return entries[selection_index].value;
}

void GuiEntryList::entriesChanged()
{
}

void GuiEntryList::callback()
{
    if (func)
    {
        func_t f = func;
        if (selection_index >= 0 && selection_index < (int)entries.size())
            f(selection_index, entries[selection_index].value);
        else
            f(selection_index, "");
    }
}
