#ifndef ROTATING_MODEL_VIEW_H
#define ROTATING_MODEL_VIEW_H

#include "gui/gui2_element.h"

class GuiRotatingModelView : public GuiElement
{
private:
    //TODO: P<ModelData> model;
public:
    GuiRotatingModelView(GuiContainer* owner, string id /*TODO, P<ModelData> model*/);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//ROTATING_MODEL_VIEW_H
