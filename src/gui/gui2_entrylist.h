#ifndef GUI2_ENTRYLIST_H
#define GUI2_ENTRYLIST_H

#include "gui2_element.h"
#include "gui2_button.h"
#include "gui2_scrollbar.h"

class GuiEntryList : public GuiElement
{
public:
    typedef std::function<void(int index, string value)> func_t;

private:
    class GuiEntry
    {
    public:
        string name;
        string value;
        GuiEntry(string name, string value) : name(name), value(value) {}
    };
    
protected:
    std::vector<GuiEntry> entries;
    int selection_index;
    func_t func;
public:
    GuiEntryList(GuiContainer* owner, string id, func_t func);

    GuiEntryList* setOptions(std::vector<string> options);
    GuiEntryList* setOptions(std::vector<string> options, std::vector<string> values);

    void setEntryName(int index, string name);
    void setEntryValue(int index, string value);
    void setEntry(int index, string name, string value);

    int addEntry(string name, string value);
    int indexByValue(string value);
    void removeEntry(int index);
    int entryCount();
    string getEntryName(int index);
    string getEntryValue(int index);
    
    int getSelectionIndex();
    GuiEntryList* setSelectionIndex(int index);
    string getSelectionValue();
protected:
    void callback();
private:
    virtual void entriesChanged();
};

#endif//GUI2_ENTRYLIST_H
