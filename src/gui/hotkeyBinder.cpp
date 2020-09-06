#include "engine.h"
#include "hotkeyConfig.h"
#include "hotkeyBinder.h"

GuiHotkeyBinder::GuiHotkeyBinder(GuiContainer* owner, string id, string text)
: GuiTextEntry(owner, id, text), has_focus(false)
{
}

void GuiHotkeyBinder::onFocusGained()
{
    sf::Keyboard::setVirtualKeyboardVisible(true);
    has_focus = true;
}

void GuiHotkeyBinder::onFocusLost()
{
    sf::Keyboard::setVirtualKeyboardVisible(false);
    has_focus = false;
}

bool GuiHotkeyBinder::onKey(sf::Event::KeyEvent key, int unicode)
{
    if (has_focus && key.code != sf::Keyboard::Unknown)
    {
        if (key.code == sf::Keyboard::Escape
            || key.code == sf::Keyboard::Home
            || key.code == sf::Keyboard::F1)
        {
            text = "";
            return true;
        }
        string key_name = hotkeys.getStringForKey(key.code);

        if (key_name.length() > 0) {
            text = key_name;
            return true;
        }
    }

    return false;
}
