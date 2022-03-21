#ifndef GLOBAL_MESSAGE_H
#define GLOBAL_MESSAGE_H

#include "gui/gui2_element.h"

class GuiPanel;
class GuiLabel;

class GuiGlobalMessage : public GuiElement
{
private:
    GuiPanel* box;
    GuiLabel* label;
public:
    GuiGlobalMessage(GuiContainer* owner);

    virtual void onUpdate() override;
};

#endif//GLOBAL_MESSAGE_H
