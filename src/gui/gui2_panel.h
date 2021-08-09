#ifndef GUI2_PANEL_H
#define GUI2_PANEL_H

#include "gui2_element.h"

class GuiPanel : public GuiElement
{
public:
    GuiPanel(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(glm::vec2 position) override;
};

#endif//GUI2_PANEL_H
