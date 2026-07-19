#pragma once

#include "gui2_entrylist.h"


class GuiArrowButton;
class GuiThemeStyle;
class GuiToggleButton;

class GuiSelector : public GuiEntryList
{
protected:
    float text_size = 30.0f;
    sp::Alignment text_alignment;
    GuiArrowButton* left;
    GuiArrowButton* right;
    GuiElement* popup;
    std::vector<GuiToggleButton*> popup_buttons;
    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;
public:
    GuiSelector(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onFocusLost() override;

    GuiSelector* setTextSize(float size);
};
