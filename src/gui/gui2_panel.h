#ifndef GUI2_PANEL_H
#define GUI2_PANEL_H

#include "gui2_element.h"


class GuiThemeStyle;
class GuiPanel : public GuiElement
{
protected:
    const GuiThemeStyle* style;
public:
    GuiPanel(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
};

#endif//GUI2_PANEL_H
