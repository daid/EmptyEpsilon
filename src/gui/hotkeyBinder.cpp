#include "hotkeyBinder.h"
#include <i18n.h>
#include "engine.h"
#include "hotkeyConfig.h"
#include "theme.h"

// Track which binder and which key are actively performing a rebind.
static GuiHotkeyBinder* active_rebinder = nullptr;
static sp::io::Keybinding* active_key = nullptr;

GuiHotkeyBinder::GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key, sp::io::Keybinding::Type display_filter, sp::io::Keybinding::Type capture_filter)
: GuiElement(owner, id), key(key), display_filter(display_filter), capture_filter(capture_filter)
{
    // Use textentry theme styles for binder inputs.
    // Someday, this should allow for icon representations instead of relying
    // on text.
    front_style = theme->getStyle("textentry.front");
    back_style = theme->getStyle("textentry.back");
}

bool GuiHotkeyBinder::isAnyRebinding()
{
    return active_rebinder != nullptr;
}

void GuiHotkeyBinder::startRebind()
{
    active_rebinder = this;
    active_key = key;
    // Strip globally prohibited types from the capture filter so they are
    // skipped rather than ending the rebind when the user triggers them.
    sp::io::Keybinding::Type effective_capture = static_cast<sp::io::Keybinding::Type>(
        static_cast<int>(capture_filter) & ~static_cast<int>(sp::io::Keybinding::getGloballyProhibitedTypes()));
    key->startUserRebind(effective_capture);
}

void GuiHotkeyBinder::clearFilteredKeys()
{
    // Filter binds for this control by their type.
    int count = 0;
    while (key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
    for (int i = count - 1; i >= 0; --i)
        if (key->getKeyType(i) & display_filter) key->removeKey(i);
}

bool GuiHotkeyBinder::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    // If this binder is already rebinding, just take the input and skip this.
    // This should allow binding middle/right-click without also changing the
    // binder's state at the same time.
    if (active_rebinder == this) return true;

    // Left click: Assign input. Middle click: Add input.
    // Right click: Remove last input. Ignore all other mouse buttons.
    if (button == sp::io::Pointer::Button::Left) clearFilteredKeys();
    if (button == sp::io::Pointer::Button::Right)
    {
        int count = 0;
        while (key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
        for (int i = count - 1; i >= 0; --i)
        {
            if (key->getKeyType(i) & display_filter)
            {
                key->removeKey(i);
                break;
            }
        }
    }

    if (button == sp::io::Pointer::Button::Left || button == sp::io::Pointer::Button::Middle)
    {
        // Delay startUserRebind until onMouseUp so that the triggering
        // mouse click is not immediately captured as the new binding.
        if (capture_filter & sp::io::Keybinding::Type::Mouse)
            pending_rebind = true;
        else
            startRebind();
    }

    return true;
}

void GuiHotkeyBinder::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    // Complete a pending rebind action.
    if (pending_rebind)
    {
        pending_rebind = false;
        startRebind();
    }
}

void GuiHotkeyBinder::onDraw(sp::RenderTarget& renderer)
{
    // Clear the active rebind indicator only when the tracked key's rebind
    // completes.
    if (active_key != nullptr && !active_key->isUserRebinding())
    {
        active_rebinder = nullptr;
        active_key = nullptr;
    }

    bool is_my_rebind = (active_rebinder == this);
    focus = is_my_rebind;

    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    renderer.drawStretched(rect, back.texture, back.color);

    string text;

    // If this is the active rebinder, update its state to indicate that it's
    // ready for input. Otherwise, list the associated binds.
    // TODO: This list can get quite long. What should it do on overflow?
    if (is_my_rebind) text = tr("[New input]");
    else
    {
        for (int n = 0; key->getKeyType(n) != sp::io::Keybinding::Type::None; n++)
        {
            if (key->getKeyType(n) & display_filter)
            {
                if (!text.empty()) text += ",";
                text += key->getHumanReadableKeyName(n);
            }
        }
    }

    renderer.drawText(sp::Rect(rect.position.x + 16.0f, rect.position.y, rect.size.x, rect.size.y), text, sp::Alignment::CenterLeft, front.size, front.font, front.color);
}
