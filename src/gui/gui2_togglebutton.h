#ifndef GUI2_TOGGLEBUTTON_H
#define GUI2_TOGGLEBUTTON_H

#include "gui2_button.h"

class GuiToggleButton : public GuiButton
{
public:
    typedef std::function<void(bool active)> func_t;
private:
    bool value;
    func_t toggle_func;

public:
    GuiToggleButton(GuiContainer* owner, string id, string text, func_t func);

    bool getValue() const;
    GuiToggleButton* setValue(bool value);
private:
    void onClick();
};

#endif//GUI2_TOGGLEBUTTON_H
