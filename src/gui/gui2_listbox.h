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
    sp::Alignment text_alignment;
    sf::Color selected_color;
    sf::Color unselected_color;
    GuiScrollbar* scroll;
    sp::Rect last_rect;
public:
    GuiListbox(GuiContainer* owner, string id, func_t func);

    GuiListbox* setTextSize(float size);
    GuiListbox* setButtonHeight(float height);

    GuiListbox* scrollTo(int index);

    virtual void onDraw(sp::RenderTarget& target);
    virtual bool onMouseDown(glm::vec2 position);
    virtual void onMouseUp(glm::vec2 position);
private:
    virtual void entriesChanged();
};

#endif//GUI2_LISTBOX_H
