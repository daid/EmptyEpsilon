#include "engine.h"
#include "hotkeyConfig.h"
#include "hotkeyBinder.h"

GuiHotkeyBinder::GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key)
: GuiElement(owner, id), has_focus(false), key(key)
{
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
    if (key->isUserRebinding())
        renderer.drawStretched(rect, "gui/widget/TextEntryBackground.focused.png", selectColor(colorConfig.text_entry.background));
    else
        renderer.drawStretched(rect, "gui/widget/TextEntryBackground.png", selectColor(colorConfig.text_entry.background));
    string text = key->getHumanReadableKeyName(0);
    for(int n=1; key->getKeyType(n) != sp::io::Keybinding::Type::None; n++)
        text += "," + key->getHumanReadableKeyName(n);
    if (key->isUserRebinding())
        text = "[Press new key]";
    renderer.drawText(sp::Rect(rect.position.x + 16, rect.position.y, rect.size.x, rect.size.y), text, sp::Alignment::CenterLeft, 30, main_font, selectColor(colorConfig.text_entry.forground));
}
