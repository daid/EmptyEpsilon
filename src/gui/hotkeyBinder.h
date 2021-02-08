#ifndef HOTKEYBINDER_H
#define HOTKEYBINDER_H

#include "gui2_textentry.h"

class HotkeyConfig;

class GuiHotkeyBinder : public GuiTextEntry
{
private:
    bool has_focus;
public:
    GuiHotkeyBinder(GuiContainer* owner, string id, string text);

    virtual void onFocusGained() override;
    virtual void onFocusLost() override;
    virtual bool onKey(sf::Event::KeyEvent key, int unicode) override;
};

#endif //HOTKEYBINDER_H
