#ifndef ROTATING_MODEL_VIEW_H
#define ROTATING_MODEL_VIEW_H

#include "gui/gui2_element.h"
#include "components/rendering.h"

class GuiRotatingModelView : public GuiElement
{
private:
    sp::ecs::Entity &entity;
public:
    GuiRotatingModelView(GuiContainer* owner, string id, sp::ecs::Entity& entity);

    virtual void onDraw(sp::RenderTarget& target) override;
};

#endif//ROTATING_MODEL_VIEW_H
