#include "engine.h"
#include "hotkeyConfig.h"
#include "hotkeyBinder.h"
#include "theme.h"


GuiHotkeyBinder::GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key)
: GuiElement(owner, id), has_focus(false), key(key)
{
    front_style = theme->getStyle("textentry.front");
    back_style = theme->getStyle("textentry.back");
}

bool GuiHotkeyBinder::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (button != sp::io::Pointer::Button::Middle)
        key->clearKeys();
    if (button != sp::io::Pointer::Button::Right)
        key->startUserRebind(sp::io::Keybinding::Type::Keyboard | sp::io::Keybinding::Type::Joystick | sp::io::Keybinding::Type::Controller | sp::io::Keybinding::Type::Virtual);
    return true;
}

void GuiHotkeyBinder::onDraw(sp::RenderTarget& renderer)
{
    focus = key->isUserRebinding();
    auto back = back_style->get(getState());
    auto front = front_style->get(getState());

    renderer.drawStretched(rect, back.texture, back.color);

    string text = key->getHumanReadableKeyName(0);
    for(int n=1; key->getKeyType(n) != sp::io::Keybinding::Type::None; n++)
        text += "," + key->getHumanReadableKeyName(n);
    if (key->isUserRebinding())
        text = "[Press new key]";
    renderer.drawText(sp::Rect(rect.position.x + 16, rect.position.y, rect.size.x, rect.size.y), text, sp::Alignment::CenterLeft, front.size, front.font, front.color);
}
