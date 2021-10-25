#ifndef HOTKEYBINDER_H
#define HOTKEYBINDER_H

#include "gui2_element.h"

class HotkeyConfig;

class GuiHotkeyBinder : public GuiElement
{
private:
    bool has_focus;
    sp::io::Keybinding* key;
public:
    GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onDraw(sp::RenderTarget& renderer) override;
};

#endif //HOTKEYBINDER_H
