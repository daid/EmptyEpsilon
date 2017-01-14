#ifndef GUI2_LISTBOX_H
#define GUI2_LISTBOX_H

#include "gui2_element.h"
#include "gui2_entrylist.h"
#include "gui2_button.h"
#include "gui2_scrollbar.h"

class GuiListbox : public GuiEntryList
{
protected:
    std::vector<GuiButton*> buttons;
    float text_size;
    float button_height;
    EGuiAlign text_alignment;
    sf::Color selected_color;
    sf::Color unselected_color;
    GuiScrollbar* scroll;
    sf::FloatRect last_rect;
public:
    GuiListbox(GuiContainer* owner, string id, func_t func);

    GuiListbox* setTextSize(float size);
    GuiListbox* setButtonHeight(float height);

    virtual void onDraw(sf::RenderTarget& window);
    virtual bool onMouseDown(sf::Vector2f position);
    virtual void onMouseUp(sf::Vector2f position);
private:
    virtual void entriesChanged();
};

#endif//GUI2_LISTBOX_H
