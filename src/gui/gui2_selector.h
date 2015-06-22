#ifndef GUI2_SELECTOR_H
#define GUI2_SELECTOR_H

#include "gui2_entrylist.h"

class GuiSelector : public GuiEntryList
{
protected:
    float text_size;
    EGuiAlign text_alignment;
public:
    GuiSelector(GuiContainer* owner, string id, func_t func);

    virtual void onDraw(sf::RenderTarget& window);
    
    GuiSelector* setTextSize(float size);
};

#endif//GUI2_SELECTOR_H
