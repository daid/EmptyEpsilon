#ifndef GUI2_PANEL_H
#define GUI2_PANEL_H

#include "gui2_element.h"

class GuiPanel : public GuiElement
{
public:
    GuiPanel(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& window) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, int id) override;
};

#endif//GUI2_PANEL_H
