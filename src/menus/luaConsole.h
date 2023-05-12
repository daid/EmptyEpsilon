#pragma once

#include "result.h"
#include "gui/gui2_canvas.h"

class GuiTextEntry;
class LuaConsole : public GuiCanvas
{
public:
    LuaConsole();

    template<typename T> static void checkResult(sp::Result<T>& r) {
        if (r.isErr()) {
            LOG(Error, "LUA-Error:", r.error());
            addLog(r.error());
        }
    }
    static void addLog(const string& message);

private:
    std::vector<string> log_messages;
    GuiElement* top;
    GuiTextEntry* log;
    GuiTextEntry* entry;
};
