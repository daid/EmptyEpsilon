#ifndef ROTATING_MODEL_VIEW_H
#define ROTATING_MODEL_VIEW_H

#include "gui/gui2_element.h"
#include "modelData.h"

class GuiRotatingModelView : public GuiElement
{
private:
    P<ModelData> model;
public:
    GuiRotatingModelView(GuiContainer* owner, string id, P<ModelData> model);

    virtual void onDraw(sf::RenderTarget& window);
};

#endif//ROTATING_MODEL_VIEW_H
