#ifndef GUI2_LISTBOX_H
#define GUI2_LISTBOX_H

#include "gui2_element.h"
#include "gui2_entrylist.h"
#include "gui2_togglebutton.h"
#include "gui2_scrollbar.h"

class GuiListbox : public GuiEntryList
{
protected:
    std::vector<GuiToggleButton*> buttons;
    float text_size;
    float button_height;
    sp::Alignment text_alignment;
    glm::u8vec4 selected_color;
    glm::u8vec4 unselected_color;
    GuiScrollbar* scroll;
    sp::Rect last_rect;
public:
    GuiListbox(GuiContainer* owner, string id, func_t func);

    GuiListbox* setTextSize(float size);
    GuiListbox* setButtonHeight(float height);

    GuiListbox* scrollTo(int index);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
private:
    virtual void entriesChanged() override;
};

#endif//GUI2_LISTBOX_H
