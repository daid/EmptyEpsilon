#pragma once

#include "gui/gui2_canvas.h"
#include "gui/layout/layout.h"
#include "Updatable.h"
#include "timer.h"


class GuiTextEntry;
class LuaConsole : public GuiCanvas, public Updatable
{
public:
    LuaConsole();

    static void addLog(const string& message);

    void update(float delta) override;
private:
    std::vector<string> log_messages;
    GuiElement* top;
    GuiTextEntry* log;
    GuiTextEntry* entry;

    bool is_open = false;
    std::vector<sp::SystemTimer> message_show_timers;
    string last_error;
};
