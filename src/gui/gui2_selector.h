#ifndef GUI2_SELECTOR_H
#define GUI2_SELECTOR_H

#include "gui2_entrylist.h"

class GuiArrowButton;

class GuiSelector : public GuiEntryList
{
protected:
    float text_size;
    EGuiAlign text_alignment;
    GuiArrowButton* left;
    GuiArrowButton* right;
    GuiElement* popup;
    std::vector<GuiButton*> popup_buttons;
public:
    GuiSelector(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sf::RenderTarget& window) override;
    virtual bool onMouseDown(sf::Vector2f position) override;
    virtual void onMouseUp(sf::Vector2f position) override;
    
    GuiSelector* setTextSize(float size);
};

#endif//GUI2_SELECTOR_H
