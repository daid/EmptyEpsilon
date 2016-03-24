#ifndef GUI_ROTATING_MODEL_VIEW_H
#define GUI_ROTATING_MODEL_VIEW_H

#include "gui/gui2.h"
#include "modelData.h"

class GuiRotatingModelView : public GuiElement
{
private:
    P<ModelData> model;
public:
    GuiRotatingModelView(GuiContainer* owner, string id, P<ModelData> model);
    
    virtual void onDraw(sf::RenderTarget& window);
};

#endif//GUI_COMBAT_MANEUVER_H

