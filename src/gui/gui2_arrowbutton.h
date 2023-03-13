#ifndef GUI2_ARROWBUTTON_H
#define GUI2_ARROWBUTTON_H

#include "gui2_button.h"

class GuiArrowButton : public GuiButton
{
protected:
    float angle;
public:
    GuiArrowButton(GuiContainer* owner, string id, float angle, func_t func);

    virtual void onDraw(sp::RenderTarget& renderer) override;
};

#endif//GUI2_ARROWBUTTON_H
