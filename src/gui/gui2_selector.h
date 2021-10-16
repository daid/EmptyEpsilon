#ifndef GUI2_SELECTOR_H
#define GUI2_SELECTOR_H

#include "gui2_entrylist.h"

class GuiArrowButton;

class GuiSelector : public GuiEntryList
{
protected:
    float text_size;
    sp::Alignment text_alignment;
    GuiArrowButton* left;
    GuiArrowButton* right;
    GuiElement* popup;
    std::vector<GuiButton*> popup_buttons;
public:
    GuiSelector(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;

    GuiSelector* setTextSize(float size);
};

#endif//GUI2_SELECTOR_H
