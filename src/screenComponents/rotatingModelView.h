#ifndef ROTATING_MODEL_VIEW_H
#define ROTATING_MODEL_VIEW_H

#include "gui/gui2_element.h"
#include "components/rendering.h"

class GuiRotatingModelView : public GuiElement
{
private:
    MeshRenderComponent *mesh;
public:
    GuiRotatingModelView(GuiContainer* owner, string id, MeshRenderComponent *mesh);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//ROTATING_MODEL_VIEW_H
