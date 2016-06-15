#ifndef ON_SCREEN_KEYBOARD_H
#define ON_SCREEN_KEYBOARD_H

#include "gui/gui2_element.h"

class GuiTextEntry;

class OnScreenKeyboardControl : public GuiElement
{
public:
    OnScreenKeyboardControl(GuiContainer* owner, GuiTextEntry* target);
private:
    GuiTextEntry* target;
    
    void addButtonsToRow(GuiContainer* row, const char* button_keys);
};

#endif//ON_SCREEN_KEYBOARD_H
