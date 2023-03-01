#ifndef DOCKING_BUTTON_H
#define DOCKING_BUTTON_H

#include "gui/gui2_button.h"

class GuiDockingButton : public GuiButton
{
public:
    GuiDockingButton(GuiContainer* owner, string id);

    virtual void onUpdate() override;
    virtual void onDraw(sp::RenderTarget& target) override;
private:
    void click();

    sp::ecs::Entity findDockingTarget();
};

#endif//DOCKING_BUTTON_H
