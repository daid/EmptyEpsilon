#ifndef LISTBOX_H
#define LISTBOX_H

#include "gui2.h"
#include "gui2_button.h"
#include "gui2_scrollbar.h"

class GuiListbox : public GuiElement, private GuiContainer
{
public:
    typedef std::function<void(int index, string value)> func_t;

private:
    class GuiListboxEntry
    {
    public:
        string name;
        string value;
        GuiListboxEntry(string name, string value) : name(name), value(value) {}
    };
    
protected:
    std::vector<GuiListboxEntry> entries;
    std::vector<GuiButton*> buttons;
    int selection_index;
    float text_size;
    float button_height;
    EGuiAlign text_alignment;
    sf::Color selected_color;
    sf::Color unselected_color;
    func_t func;
    GuiScrollbar* scroll;
public:
    GuiListbox(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    virtual GuiElement* onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
    
    int addEntry(string name, string value);
    int indexByValue(string value);
    void removeEntry(int index);
    
    void setSelectionIndex(int index);
private:
    void updateButtons();
};

#endif//LISTBOX_H
